import 'dart:async';
import 'dart:io';

import 'package:ecommerce_sqlite_clean/core/exception.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts({
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  }) async {
    try {
      // Fetch from API
      final productModels = await remoteDataSource.getProducts(
        offset: offset,
        limit: limit,
        title: title,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // Save to SQLite
      if (productModels.isNotEmpty) {
        await localDataSource.saveProducts(productModels);
      }

      // Convert models to domain entities
      return productModels.map((model) => model.toEntity()).toList();
    } on SocketException {
      // No internet connection
      throw NetworkException('No internet connection');
    } on http.ClientException {
      // Network error
      throw NetworkException('Unable to connect to server');
    } on TimeoutException {
      // Request timeout
      throw NetworkException('Connection timeout');
    } catch (e) {
      print('Error fetching from remote: $e');
      throw NetworkException('Something went wrong');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  }) async {
    // 1. Try to fetch from remote
    try {
      final remoteProducts = await remoteDataSource.getProductsByCategory(
        categoryId,
        offset: offset,
        limit: limit,
        title: title,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // 2. Save to local (only if offset is 0? No, save all)
      await localDataSource.saveProducts(remoteProducts);

      // 3. Return updated list
      return remoteProducts.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is ServerException) {
        // 4. If remote fails, fetch from local
        final localProducts = await localDataSource.getProductsByCategory(
          categoryId,
          offset: offset,
          limit: limit,
        );
        if (localProducts.isNotEmpty) {
          return localProducts.map((e) => e.toEntity()).toList();
        }
        throw NetworkException(e.message);
      } else {
        // Fallback for other errors with local check
        try {
          final localProducts = await localDataSource.getProductsByCategory(
            categoryId,
            offset: offset,
            limit: limit,
          );
          if (localProducts.isNotEmpty) {
            return localProducts.map((e) => e.toEntity()).toList();
          }
        } catch (_) {} // Ignore local error if both fail

        if (e is Exception) {
          throw NetworkException(e.toString());
        }
        rethrow;
      }
    }
  }

  @override
  Future<List<Product>> getAllLocalProducts() async {
    final productModels = await localDataSource.getProducts();
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final model = await localDataSource.getProduct(id);
    return model?.toEntity();
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearProducts();
  }
}
