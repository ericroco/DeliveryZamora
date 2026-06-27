import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';

// Dependencias
final dioProvider = Provider<Dio>((ref) => Dio());

final notificationsDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSourceImpl(ref.read(dioProvider));
});

final notificationsRepositoryProvider = Provider((ref) {
  return NotificationsRepositoryImpl(ref.read(notificationsDataSourceProvider));
});

final getNotificationsProvider = Provider((ref) {
  return GetNotifications(ref.read(notificationsRepositoryProvider));
});

final markNotificationReadProvider = Provider((ref) {
  return MarkNotificationRead(ref.read(notificationsRepositoryProvider));
});

// Notifier
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final GetNotifications _getNotifications;
  final MarkNotificationRead _markNotificationRead;

  NotificationsNotifier(this._getNotifications, this._markNotificationRead) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _markNotificationRead(id);
      
      // Update local state
      if (state.value != null) {
        final updatedList = state.value!.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      // Handle error gracefully if needed
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationEntity>>>((ref) {
  return NotificationsNotifier(
    ref.read(getNotificationsProvider),
    ref.read(markNotificationReadProvider),
  );
});
