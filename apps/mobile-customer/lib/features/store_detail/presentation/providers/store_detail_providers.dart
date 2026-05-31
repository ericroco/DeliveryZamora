import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/features/home/domain/entities/product.dart';

// Mock product catalog per store — replace with Dio call when API is ready
final productsByStoreProvider =
    Provider.family<List<Product>, String>((ref, storeId) {
  return _mockProducts[storeId] ?? [];
});

const _mockProducts = <String, List<Product>>{
  '1': [
    Product(
      id: 'p1_1',
      storeId: '1',
      name: 'Cuy asado entero',
      description: 'Criado en casa, asado en leña con papas doradas y salsa de maní.',
      price: 12.00,
      categoryLabel: 'Platos fuertes',
      imageUrl: 'assets/images/cuy-asado.jpg',
    ),
    Product(
      id: 'p1_2',
      storeId: '1',
      name: 'Media porción de cuy',
      description: 'La mitad del cuy con guarnición completa.',
      price: 6.50,
      categoryLabel: 'Platos fuertes',
      imageUrl: 'assets/images/cuy-asado.jpg',
    ),
    Product(
      id: 'p1_3',
      storeId: '1',
      name: 'Tilapia frita',
      description: 'Tilapia del río Zamora, frita con patacones y ensalada.',
      price: 7.00,
      categoryLabel: 'Platos fuertes',
      imageUrl: 'assets/images/ayampacos.jpg',
    ),
    Product(
      id: 'p1_4',
      storeId: '1',
      name: 'Jugo de caña',
      description: 'Caña fresca molida al momento.',
      price: 1.50,
      categoryLabel: 'Bebidas',
    ),
    Product(
      id: 'p1_5',
      storeId: '1',
      name: 'Chicha de jora',
      description: 'Chicha artesanal de maíz morado.',
      price: 1.00,
      categoryLabel: 'Bebidas',
    ),
  ],
  '2': [
    Product(
      id: 'p2_1',
      storeId: '2',
      name: 'Ceviche de camarón',
      description: 'Camarón fresco con limón, tomate y cilantro. Lleva chifles.',
      price: 8.50,
      categoryLabel: 'Ceviches',
      imageUrl: 'assets/images/ceviche.jpg',
    ),
    Product(
      id: 'p2_2',
      storeId: '2',
      name: 'Ceviche mixto',
      description: 'Camarón, calamar y pulpo. Porción grande.',
      price: 11.00,
      categoryLabel: 'Ceviches',
      imageUrl: 'assets/images/ceviche.jpg',
    ),
    Product(
      id: 'p2_3',
      storeId: '2',
      name: 'Arroz con menestra y pescado',
      description: 'Filete de tilapia apanada con menestra de lenteja y arroz.',
      price: 6.00,
      categoryLabel: 'Platos del día',
      imageUrl: 'assets/images/caldo-corroncho.jpg',
    ),
    Product(
      id: 'p2_4',
      storeId: '2',
      name: 'Agua con gas',
      description: '',
      price: 0.75,
      categoryLabel: 'Bebidas',
    ),
  ],
  '3': [
    Product(
      id: 'p3_1',
      storeId: '3',
      name: 'Flan de caramelo',
      description: 'Casero, horneado a diario. Porción individual con crema.',
      price: 2.50,
      categoryLabel: 'Postres',
      imageUrl: 'assets/images/postres-caseros.jpg',
    ),
    Product(
      id: 'p3_2',
      storeId: '3',
      name: 'Torta de chocolate',
      description: 'Tres capas, relleno de manjar y ganache.',
      price: 3.50,
      categoryLabel: 'Postres',
      imageUrl: 'assets/images/postres-caseros.jpg',
    ),
    Product(
      id: 'p3_3',
      storeId: '3',
      name: 'Gelatina de frutilla',
      description: 'Gelatina casera con frutillas frescas y crema chantilly.',
      price: 1.75,
      categoryLabel: 'Postres',
      imageUrl: 'assets/images/postres-caseros.jpg',
    ),
    Product(
      id: 'p3_4',
      storeId: '3',
      name: 'Caja de 12 alfajores',
      description: 'Rellenos de manjar y cubiertos de azúcar glass.',
      price: 5.00,
      categoryLabel: 'Para llevar',
      imageUrl: 'assets/images/postres-caseros.jpg',
    ),
  ],
};
