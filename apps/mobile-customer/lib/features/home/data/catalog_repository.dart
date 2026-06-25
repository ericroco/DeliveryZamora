import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/core/network/api_client.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';

class CatalogHomeData {
  const CatalogHomeData({
    required this.categories,
    required this.featuredStores,
  });

  final List<StoreCategory> categories;
  final List<Store> featuredStores;
}

class CatalogRepository {
  const CatalogRepository(this._dio);

  final Dio _dio;

  Future<CatalogHomeData> getHome() async {
    final res = await _dio.get<Map<String, dynamic>>('/catalog');
    final data = res.data!;
    return CatalogHomeData(
      categories: (data['categories'] as List)
          .map((e) => StoreCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredStores: (data['featuredStores'] as List)
          .map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);
