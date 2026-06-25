class StoreCategory {
  const StoreCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? iconUrl;

  factory StoreCategory.fromJson(Map<String, dynamic> json) => StoreCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        iconUrl: json['iconUrl'] as String?,
      );
}

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.address,
    this.logoUrl,
    this.coverUrl,
    this.ratingAvg,
    this.ratingCount,
    this.openingHours,
  });

  final String id;
  final String name;
  final StoreCategory category;
  final String? description;
  final String? address;
  final String? logoUrl;
  final String? coverUrl;
  final double? ratingAvg;
  final int? ratingCount;
  final String? openingHours;

  String get displayRating =>
      ratingAvg != null ? ratingAvg!.toStringAsFixed(1) : '—';

  bool get isCasero => category.slug == 'caseros';

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        category: StoreCategory.fromJson(
          json['category'] as Map<String, dynamic>,
        ),
        description: json['description'] as String?,
        address: json['address'] as String?,
        logoUrl: json['logoUrl'] as String?,
        coverUrl: json['coverUrl'] as String?,
        ratingAvg: (json['ratingAvg'] as num?)?.toDouble(),
        ratingCount: json['ratingCount'] as int?,
        openingHours: json['openingHours'] as String?,
      );
}
