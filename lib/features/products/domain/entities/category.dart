class Category {
  final int id;
  final String name;
  final String slug;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
