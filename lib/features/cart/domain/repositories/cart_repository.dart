import 'package:ecommerce_sqlite_clean/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/entities/product.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(Product product);
  Future<void> removeFromCart(Product product);
  Future<void> updateQuantity(Product product, int quantity);
  Future<void> clearCart();
}
