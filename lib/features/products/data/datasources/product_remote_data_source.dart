import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  });

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts({
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  }) async {
    final queryParams = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (title != null && title.isNotEmpty) 'title': title,
      if (priceMin != null) 'price_min': priceMin.toInt().toString(),
      if (priceMax != null) 'price_max': priceMax.toInt().toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/products',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  }) async {
    final queryParams = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (title != null && title.isNotEmpty) 'title': title,
      if (priceMin != null) 'price_min': priceMin.toInt().toString(),
      if (priceMax != null) 'price_max': priceMax.toInt().toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/categories/$categoryId/products',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load category products: ${response.statusCode}',
      );
    }
  }
}
