import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/features/home/data/catalog_repository.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';

final catalogHomeProvider = FutureProvider<CatalogHomeData>((ref) {
  return ref.watch(catalogRepositoryProvider).getHome();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final storeByIdProvider = Provider.family<Store?, String>((ref, storeId) {
  final catalogAsync = ref.watch(catalogHomeProvider);
  return catalogAsync.value?.featuredStores
      .where((s) => s.id == storeId)
      .firstOrNull;
});

final filteredStoresProvider = Provider<List<Store>>((ref) {
  final catalogAsync = ref.watch(catalogHomeProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return catalogAsync.when(
    data: (data) {
      if (selectedCategory == null) return data.featuredStores;
      return data.featuredStores
          .where((s) => s.category.id == selectedCategory)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
