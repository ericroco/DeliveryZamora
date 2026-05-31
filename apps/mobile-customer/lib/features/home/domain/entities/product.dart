class Product {
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryLabel,
    this.imageUrl,
    this.isAvailable = true,
  });

  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String categoryLabel;
  final String? imageUrl;
  final bool isAvailable;
}
