class Store {
  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.tag,
    required this.rating,
    required this.deliveryTime,
    required this.distance,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String tag;
  final double rating;
  final String deliveryTime;
  final String distance;
  final String? imageUrl;

  bool get isCasero => category == 'Caseros';
}
