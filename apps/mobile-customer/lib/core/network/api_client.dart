import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/core/auth/data/auth_repository.dart';
import 'package:mobile_customer/core/auth/auth_provider.dart';
import 'package:mobile_customer/core/constants/api_constants.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(_AuthInterceptor(ref));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token =
        await _ref.read(authRepositoryProvider).getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _ref.read(authStateProvider.notifier).logout();
    }
    handler.next(err);
  }
}
