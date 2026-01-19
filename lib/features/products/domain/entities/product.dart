class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final String category;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.images,
    required this.category,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
