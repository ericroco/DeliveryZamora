import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';

// Mock data — replace with API calls when backend is ready
const _mockStores = [
  Store(
    id: '1',
    name: 'Zampu Muru — Doña María',
    category: 'Caseros',
    tag: 'Cuy & Andino',
    rating: 4.8,
    deliveryTime: '35 min',
    distance: '2.3 km',
    imageUrl: 'assets/images/ayampacos.jpg',
  ),
  Store(
    id: '2',
    name: 'Cevichería Rinconcito',
    category: 'Restaurantes',
    tag: 'Mariscos',
    rating: 4.6,
    deliveryTime: '25 min',
    distance: '1.5 km',
    imageUrl: 'assets/images/ceviche.jpg',
  ),
  Store(
    id: '3',
    name: 'Doña Gladys Postres',
    category: 'Caseros',
    tag: 'Postres Caseros',
    rating: 4.9,
    deliveryTime: '20 min',
    distance: '0.8 km',
    imageUrl: 'assets/images/postres-caseros.jpg',
  ),
  Store(
    id: '4',
    name: 'Hostería El Arenal',
    category: 'Restaurantes',
    tag: 'Parrilla',
    rating: 4.5,
    deliveryTime: '40 min',
    distance: '3.1 km',
    imageUrl: 'assets/images/parrilla.jpg',
  ),
  Store(
    id: '5',
    name: 'Maderos Grill & Bar',
    category: 'Restaurantes',
    tag: 'Grill & Bar',
    rating: 4.7,
    deliveryTime: '30 min',
    distance: '2.0 km',
    imageUrl: 'assets/images/parrilla.jpg',
  ),
  Store(
    id: '6',
    name: 'Farmacia San Gabriel',
    category: 'Farmacias',
    tag: 'Medicamentos',
    rating: 4.3,
    deliveryTime: '15 min',
    distance: '1.2 km',
    imageUrl: 'assets/images/farmacia.jpg',
  ),
  Store(
    id: '7',
    name: 'Mercado Central Zamora',
    category: 'Mercados',
    tag: 'Verduras & Frutas',
    rating: 4.4,
    deliveryTime: '35 min',
    distance: '2.5 km',
    imageUrl: 'assets/images/mercado.jpg',
  ),
  Store(
    id: '8',
    name: 'Licores El Bombuscaro',
    category: 'Licores',
    tag: 'Bebidas',
    rating: 4.2,
    deliveryTime: '15 min',
    distance: '1.8 km',
  ),
];

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final storesProvider = Provider<List<Store>>((ref) => _mockStores);

final filteredStoresProvider = Provider<List<Store>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final stores = ref.watch(storesProvider);
  if (category == null) return stores;
  return stores.where((s) => s.category == category).toList();
});
