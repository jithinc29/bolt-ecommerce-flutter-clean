import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }
}
