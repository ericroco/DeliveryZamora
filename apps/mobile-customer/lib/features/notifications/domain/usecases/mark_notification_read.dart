import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  final NotificationsRepository repository;

  MarkNotificationRead(this.repository);

  Future<void> call(String id) async {
    return await repository.markAsRead(id);
  }
}
