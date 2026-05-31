import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/cart/presentation/providers/cart_provider.dart';

const double _deliveryFee = 1.50;
const double _serviceFee = 0.25;

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final total = subtotal + _deliveryFee + _serviceFee;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Tu pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Vaciar carrito'),
                    content: const Text('¿Eliminar todos los productos del carrito?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Vaciar'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(cartProvider.notifier).clear();
                }
              },
              child: const Text(
                'Vaciar',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                  ),
                ),
                _OrderSummary(
                  subtotal: subtotal,
                  deliveryFee: _deliveryFee,
                  serviceFee: _serviceFee,
                  total: total,
                  onCheckout: () => context.push('/checkout'),
                ),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(cartProvider.notifier).remove(item.product.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.caseroBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: AppColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(cartProvider.notifier).add(item.product),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotal),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Envío', value: deliveryFee),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Tarifa de servicio', value: serviceFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.cardBorder),
          ),
          _SummaryRow(label: 'Total', value: total, bold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Confirmar pedido · \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
      color: bold ? AppColors.text : AppColors.muted,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.caseroBorder),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega productos de un comercio\npara comenzar tu pedido.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Explorar comercios', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
