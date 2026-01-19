import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_sqlite_clean/features/auth/domain/entities/user_model.dart';
import 'package:ecommerce_sqlite_clean/features/auth/data/models/auth_token_model.dart';
import 'package:ecommerce_sqlite_clean/core/exception.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String email, String password);
  Future<UserModel> getProfile(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://api.escuelajs.co/api/v1';

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthTokenModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      final errorData = jsonDecode(response.body);
      throw ServerException(
        errorData['message'] ?? 'Invalid email or password',
      );
    } else {
      throw ServerException('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<UserModel> getProfile(String accessToken) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException('Failed to fetch profile: ${response.statusCode}');
    }
  }
}
