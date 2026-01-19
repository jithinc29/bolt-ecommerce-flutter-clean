import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/exception.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final http.Client client;

  CategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await client.get(
      Uri.parse('https://api.escuelajs.co/api/v1/categories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load categories');
    }
  }
}
