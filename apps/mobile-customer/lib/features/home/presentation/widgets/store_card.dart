import 'package:flutter/material.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/home/domain/entities/store.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StoreImage(store: store),
            const SizedBox(width: 12),
            Expanded(child: _StoreInfo(store: store)),
          ],
        ),
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  const _StoreImage({required this.store});

  final Store store;

  static const _gradients = <String, List<Color>>{
    'restaurantes': [Color(0xFFE8845A), Color(0xFFB85C3F)],
    'caseros': [Color(0xFFD4785C), Color(0xFF9B3D22)],
    'farmacias': [Color(0xFF5BAA8C), Color(0xFF2D7A5C)],
    'mercados': [Color(0xFF5C8A3F), Color(0xFF2D5016)],
    'licores': [Color(0xFF7B6B9A), Color(0xFF4A3D6B)],
  };

  static const _icons = <String, IconData>{
    'restaurantes': Icons.restaurant_outlined,
    'caseros': Icons.favorite_border,
    'farmacias': Icons.local_pharmacy_outlined,
    'mercados': Icons.shopping_bag_outlined,
    'licores': Icons.wine_bar_outlined,
  };

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final slug = store.category.slug;
    final colors = _gradients[slug] ?? [AppColors.primary, AppColors.accent];
    final icon = _icons[slug] ?? Icons.storefront_outlined;
    final imageUrl = store.logoUrl;

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _GradientPlaceholder(
                      colors: colors,
                      icon: icon,
                      initials: _initials(store.name),
                    ),
                  )
                : _GradientPlaceholder(
                    colors: colors,
                    icon: icon,
                    initials: _initials(store.name),
                  ),
          ),
          if (store.isCasero)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({
    required this.colors,
    required this.icon,
    required this.initials,
  });

  final List<Color> colors;
  final IconData icon;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: -8,
            right: -8,
            child: Icon(
              icon,
              size: 60,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Text(
            initials,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  const _StoreInfo({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TagBadge(store: store),
              const SizedBox(height: 5),
              Text(
                store.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (store.address != null)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 11,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          store.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (store.ratingAvg != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      store.displayRating,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final bg = store.isCasero ? AppColors.caseroTagBg : AppColors.defaultTagBg;
    final color =
        store.isCasero ? AppColors.caseroText : AppColors.defaultTagText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        store.category.name.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
