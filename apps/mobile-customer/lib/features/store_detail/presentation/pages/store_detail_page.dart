import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/cart/presentation/providers/cart_provider.dart';
import 'package:mobile_customer/features/home/domain/entities/product.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';
import 'package:mobile_customer/features/home/presentation/providers/home_providers.dart';
import 'package:mobile_customer/features/store_detail/presentation/providers/store_detail_providers.dart';

class StoreDetailPage extends ConsumerWidget {
  const StoreDetailPage({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeByIdProvider(storeId));
    final products = ref.watch(productsByStoreProvider(storeId));
    final cartCount = ref.watch(cartItemCountProvider);

    // Group products by category
    final grouped = <String, List<Product>>{};
    for (final p in products) {
      grouped.putIfAbsent(p.categoryLabel, () => []).add(p);
    }

    if (store == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _StoreHeader(store: store, cartCount: cartCount),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final categories = grouped.keys.toList();
                  if (i >= categories.length) return null;
                  final cat = categories[i];
                  final items = grouped[cat]!;
                  return _ProductSection(
                    category: cat,
                    products: items,
                    storeId: storeId,
                  );
                },
                childCount: grouped.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      bottomSheet: cartCount > 0 ? _CartBar(storeId: storeId) : null,
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.store, required this.cartCount});

  final Store store;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.bg,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.text),
        ),
      ),
      actions: [
        if (cartCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Store image or gradient fallback
            if (store.coverUrl != null || store.logoUrl != null)
              Image.network(
                (store.coverUrl ?? store.logoUrl)!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: store.isCasero ? AppColors.caseroBg : AppColors.cream,
                ),
              )
            else
              Container(
                color: store.isCasero ? AppColors.caseroBg : AppColors.cream,
              ),
            // Dark scrim over the whole image for readability
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x33000000),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          store.displayRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (store.address != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.white70),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              store.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends ConsumerWidget {
  const _ProductSection({
    required this.category,
    required this.products,
    required this.storeId,
  });

  final String category;
  final List<Product> products;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ),
        ...products.map((p) => _ProductTile(product: p, storeId: storeId)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product, required this.storeId});

  final Product product;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartStoreId = ref.watch(cartStoreIdProvider);
    final inCart = cartItems.where((i) => i.product.id == product.id);
    final qty = inCart.isEmpty ? 0 : inCart.first.quantity;
    final blocked = cartStoreId != null && cartStoreId != storeId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProductThumb(categoryLabel: product.categoryLabel, imageUrl: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _QuantityControl(
            qty: qty,
            blocked: blocked,
            onAdd: () {
              final isFirst = qty == 0;
              ref.read(cartProvider.notifier).add(product);
              if (isFirst) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} agregado al carrito'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            onRemove: () =>
                ref.read(cartProvider.notifier).remove(product.id),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.categoryLabel, this.imageUrl});

  final String categoryLabel;
  final String? imageUrl;

  static const _categoryColors = <String, List<Color>>{
    'Platos principales': [Color(0xFFE8845A), Color(0xFFB85C3F)],
    'Almuerzos':          [Color(0xFFE8845A), Color(0xFFB85C3F)],
    'Bebidas':            [Color(0xFF5BAA8C), Color(0xFF2D7A5C)],
    'Postres':            [Color(0xFFD4785C), Color(0xFF9B3D22)],
    'Pasteles':           [Color(0xFFD4785C), Color(0xFF9B3D22)],
    'Entradas':           [Color(0xFFD4A84B), Color(0xFFA07830)],
    'Medicamentos':       [Color(0xFF5B8AAA), Color(0xFF2D5A7A)],
    'Farmacia':           [Color(0xFF5B8AAA), Color(0xFF2D5A7A)],
    'Frescos':            [Color(0xFF5C8A3F), Color(0xFF2D5016)],
    'Abarrotes':          [Color(0xFF5C8A3F), Color(0xFF2D5016)],
  };

  static const _categoryIcons = <String, IconData>{
    'Platos principales': Icons.restaurant_rounded,
    'Almuerzos':          Icons.lunch_dining_rounded,
    'Bebidas':            Icons.local_cafe_rounded,
    'Postres':            Icons.cake_outlined,
    'Pasteles':           Icons.cake_outlined,
    'Entradas':           Icons.set_meal_outlined,
    'Medicamentos':       Icons.medication_outlined,
    'Farmacia':           Icons.local_pharmacy_outlined,
    'Frescos':            Icons.eco_outlined,
    'Abarrotes':          Icons.shopping_basket_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = _categoryColors[categoryLabel] ??
        [AppColors.primary, const Color(0xFF9B3D22)];
    final icon = _categoryIcons[categoryLabel] ?? Icons.fastfood_outlined;

    Widget fallback = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(icon, size: 28, color: Colors.white.withValues(alpha: 0.9)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null && imageUrl!.startsWith('assets/')
          ? Image.asset(
              imageUrl!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.qty,
    required this.blocked,
    required this.onAdd,
    required this.onRemove,
  });

  final int qty;
  final bool blocked;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return Semantics(
        button: true,
        label: blocked ? 'No disponible' : 'Agregar al carrito',
        child: GestureDetector(
          onTap: blocked ? null : onAdd,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: blocked ? AppColors.caseroBorder : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, size: 20, color: Colors.white),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Quitar uno',
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.caseroBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, size: 18, color: AppColors.primary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$qty',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Agregar uno más',
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartBar extends ConsumerWidget {
  const _CartBar({required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () => context.push('/cart'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const Text(
                'Ver carrito',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
