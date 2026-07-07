import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/core/network/api_client.dart';
import 'package:mobile_customer/core/constants/api_constants.dart';
import 'package:mobile_customer/features/orders/domain/entities/order.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return OrderRepository(dio: dio);
});

class OrderRepository {
  OrderRepository({required this.dio});

  final Dio dio;

  Future<Order> fetchOrder(String id) async {
    final response = await dio.get(ApiEndpoints.orderById(id));
    return Order.fromJson(response.data as Map<String, dynamic>);
  }
}
