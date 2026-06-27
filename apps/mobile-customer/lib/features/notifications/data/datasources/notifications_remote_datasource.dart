import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    // Simulando API Call
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationModel(
        id: '1',
        title: '¡Tu pedido está en camino!',
        body: 'El repartidor recogió tu pedido y está en camino a tu dirección.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Promoción Especial',
        body: 'Tienes 20% de descuento en tu próxima compra.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    // Implementación real comentada:
    /*
    final response = await dio.get(ApiEndpoints.notifications);
    final data = response.data as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
    */
  }

  @override
  Future<void> markAsRead(String id) async {
    // Simulando API Call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Implementación real comentada:
    /*
    await dio.patch(ApiEndpoints.readNotification(id));
    */
  }
}
