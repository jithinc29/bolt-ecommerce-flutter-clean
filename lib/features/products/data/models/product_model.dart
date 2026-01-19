import 'dart:convert';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.images,
    required super.category,
    required super.categoryId,
  });

  // From API JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      final imagesList =
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final categoryMap = json['category'] as Map<String, dynamic>?;

      return ProductModel(
        id: json['id'],
        name: json['title'] ?? 'Unknown',
        description: json['description'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: imagesList.isNotEmpty
            ? imagesList[0]
            : 'https://jubilantconsumer.com/wp-content/themes/jubilant/assets/img/product.png',
        images: imagesList,
        category: categoryMap?['name'] ?? 'Unknown',
        categoryId: categoryMap?['id'] ?? 0,
      );
    } catch (e) {
      print('Error parsing product: $e, json: $json');
      rethrow;
    }
  }

  // To JSON for SQLite
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': jsonEncode(images),
      'category': category,
      'categoryId': categoryId,
    };
  }

  // From SQLite Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      imageUrl: map['imageUrl'] as String,
      images: map['images'] != null
          ? List<String>.from(jsonDecode(map['images'] as String))
          : [],
      category: map['category'] as String,
      categoryId: map['categoryId'] as int? ?? 0,
    );
  }

  // Convert to domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      images: images,
      category: category,
      categoryId: categoryId,
    );
  }
}
