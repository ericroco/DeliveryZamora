import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/orders/domain/entities/order.dart';
import 'package:mobile_customer/shared/widgets/app_bottom_nav.dart';

final _mockOrders = [
  Order(
    id: 'ord-001',
    storeName: 'Doña Gladys Postres',
    storeCategory: 'Caseros',
    total: 7.25,
    itemCount: 3,
    status: OrderStatus.delivered,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Order(
    id: 'ord-002',
    storeName: 'Cevichería Rinconcito',
    storeCategory: 'Restaurantes',
    total: 19.50,
    itemCount: 2,
    status: OrderStatus.delivered,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Order(
    id: 'ord-003',
    storeName: 'Farmacia San Gabriel',
    storeCategory: 'Farmacias',
    total: 12.80,
    itemCount: 4,
    status: OrderStatus.delivered,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
];

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Mis pedidos',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _mockOrders.isEmpty
          ? const _EmptyOrders()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderCard(order: _mockOrders[i]),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/tracking/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                order.storeCategory == 'Caseros'
                    ? Icons.favorite_outline
                    : Icons.storefront_outlined,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.storeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.itemCount} producto${order.itemCount > 1 ? 's' : ''} · \$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.defaultTagBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.caseroBorder),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes pedidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          const Text(
            'Realiza tu primer pedido\ny aparecerá aquí.',
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
