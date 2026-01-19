import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  });
  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    required int offset,
    required int limit,
    String? title,
    double? priceMin,
    double? priceMax,
  });
  Future<List<Product>> getAllLocalProducts();
  Future<Product?> getProductById(int id);
  Future<void> clearCache();
}
