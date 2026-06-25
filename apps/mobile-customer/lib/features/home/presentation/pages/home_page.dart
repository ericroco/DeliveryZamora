import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';
import 'package:mobile_customer/features/home/presentation/providers/home_providers.dart';
import 'package:mobile_customer/features/home/presentation/widgets/category_pill.dart';
import 'package:mobile_customer/features/home/presentation/widgets/promo_banner.dart';
import 'package:mobile_customer/features/home/presentation/widgets/store_card.dart';
import 'package:mobile_customer/shared/widgets/app_bottom_nav.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogHomeProvider);
    final filteredStores = ref.watch(filteredStoresProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HomeHeader(),
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      const Text(
                        'Sin conexión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.refresh(catalogHomeProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (catalog) => SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _CategorySection(categories: catalog.categories),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: PromoBanner(),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionHeader(title: 'Lugares cerca de ti'),
                      ),
                      const SizedBox(height: 10),
                      if (filteredStores.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 32,
                          ),
                          child: Center(
                            child: Text(
                              'No hay tiendas en esta categoría',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredStores.asMap().entries.map(
                          (e) => _AnimatedStoreCard(
                            key: ValueKey(e.value.id),
                            index: e.key,
                            store: e.value,
                            onTap: () => context.push('/store/${e.value.id}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENTREGANDO EN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.accent),
                      SizedBox(width: 2),
                      Text(
                        'Zamora, Ecuador',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: 'Ver perfil',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Semantics(
              button: true,
              label: 'Buscar comida, farmacias, mercados',
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: AppColors.muted),
                  SizedBox(width: 8),
                  Text(
                    'Buscar comida, farmacias, mercados...',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({required this.categories});

  final List<StoreCategory> categories;

  static const _slugIcons = <String, IconData>{
    'restaurantes': Icons.restaurant_outlined,
    'caseros': Icons.favorite_border,
    'farmacias': Icons.local_pharmacy_outlined,
    'mercados': Icons.shopping_bag_outlined,
    'licores': Icons.wine_bar_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final icon = _slugIcons[cat.slug] ?? Icons.storefront_outlined;
          return CategoryPill(
            label: cat.name,
            icon: icon,
            isSelected: selected == cat.id,
            isCasero: cat.slug == 'caseros',
            onTap: () {
              final notifier = ref.read(selectedCategoryProvider.notifier);
              notifier.state = notifier.state == cat.id ? null : cat.id;
            },
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Lugares cerca de ti',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        Row(
          children: [
            Text(
              'Ver todo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
          ],
        ),
      ],
    );
  }
}

class _AnimatedStoreCard extends StatefulWidget {
  const _AnimatedStoreCard({
    super.key,
    required this.index,
    required this.store,
    required this.onTap,
  });

  final int index;
  final Store store;
  final VoidCallback onTap;

  @override
  State<_AnimatedStoreCard> createState() => _AnimatedStoreCardState();
}

class _AnimatedStoreCardState extends State<_AnimatedStoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  double _pressScale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 75), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => setState(() => _pressScale = 0.97);
  void _onTapUp(_) => setState(() => _pressScale = 1.0);
  void _onTapCancel() => setState(() => _pressScale = 1.0);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedScale(
              scale: _pressScale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: StoreCard(store: widget.store),
            ),
          ),
        ),
      ),
    );
  }
}
