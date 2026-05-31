import 'package:mobile_customer/features/home/domain/entities/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  final Product product;
  final int quantity;
  final String? note;

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity, String? note}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );
}
