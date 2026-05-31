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
    'Restaurantes': [Color(0xFFE8845A), Color(0xFFB85C3F)],
    'Caseros':      [Color(0xFFD4785C), Color(0xFF9B3D22)],
    'Farmacias':    [Color(0xFF5BAA8C), Color(0xFF2D7A5C)],
    'Mercados':     [Color(0xFF5C8A3F), Color(0xFF2D5016)],
    'Licores':      [Color(0xFF7B6B9A), Color(0xFF4A3D6B)],
  };

  static const _icons = <String, IconData>{
    'Restaurantes': Icons.restaurant_outlined,
    'Caseros':      Icons.favorite_border,
    'Farmacias':    Icons.local_pharmacy_outlined,
    'Mercados':     Icons.shopping_bag_outlined,
    'Licores':      Icons.wine_bar_outlined,
  };

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[store.category] ??
        [AppColors.primary, AppColors.accent];
    final icon = _icons[store.category] ?? Icons.storefront_outlined;

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: store.imageUrl != null
                ? _StoreImageWidget(
                    imageUrl: store.imageUrl!,
                    fallback: _GradientPlaceholder(colors: colors, icon: icon, initials: _initials(store.name)),
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
                child: const Icon(Icons.favorite, size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreImageWidget extends StatelessWidget {
  const _StoreImageWidget({required this.imageUrl, required this.fallback});

  final String imageUrl;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return Image.network(
      imageUrl,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
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
            child: Icon(icon, size: 60, color: Colors.white.withValues(alpha: 0.15)),
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
              _MetaRow(store: store),
              _StarRating(rating: store.rating),
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
    final color = store.isCasero ? AppColors.caseroText : AppColors.defaultTagText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        store.tag.toUpperCase(),
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 11, color: AppColors.muted),
        const SizedBox(width: 2),
        Text(store.deliveryTime,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(width: 8),
        const Icon(Icons.location_on, size: 11, color: AppColors.muted),
        const SizedBox(width: 2),
        Text(store.distance,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 13, color: AppColors.primary),
        const SizedBox(width: 2),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
