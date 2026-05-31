import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_customer/features/home/domain/entities/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void remove(String productId) {
    final idx = state.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final item = state[idx];
    if (item.quantity > 1) {
      state = [
        ...state.sublist(0, idx),
        item.copyWith(quantity: item.quantity - 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state.sublist(0, idx), ...state.sublist(idx + 1)];
    }
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

final cartStoreIdProvider = Provider<String?>((ref) {
  final items = ref.watch(cartProvider);
  return items.isEmpty ? null : items.first.product.storeId;
});
