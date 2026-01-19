import 'package:ecommerce_sqlite_clean/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_sqlite_clean/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/entities/product.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_sqlite_clean/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/cart/data/models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final ProductRepository productRepository;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.productRepository,
  });

  @override
  Future<List<CartItem>> getCartItems() async {
    final cartItemModels = await localDataSource.getCartItems();
    final List<CartItem> cartItems = [];

    for (final model in cartItemModels) {
      final product = await productRepository.getProductById(model.productId);
      if (product != null) {
        cartItems.add(CartItem(product: product, quantity: model.quantity));
      } else {
        // Handle case where product is no longer in DB?
        // Maybe remove it from cart?
        await localDataSource.removeItem(model.productId);
      }
    }
    return cartItems;
  }

  @override
  Future<void> addToCart(Product product) async {
    // Check if already in cart
    final cartItems = await localDataSource.getCartItems();
    final existingItem = cartItems.cast<CartItemModel?>().firstWhere(
      (item) => item?.productId == product.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      await localDataSource.updateQuantity(
        product.id,
        existingItem.quantity + 1,
      );
    } else {
      await localDataSource.addItem(
        CartItemModel(productId: product.id, quantity: 1),
      );
    }
  }

  @override
  Future<void> removeFromCart(Product product) async {
    final cartItems = await localDataSource.getCartItems();
    final existingItem = cartItems.cast<CartItemModel?>().firstWhere(
      (item) => item?.productId == product.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      if (existingItem.quantity > 1) {
        await localDataSource.updateQuantity(
          product.id,
          existingItem.quantity - 1,
        );
      } else {
        await localDataSource.removeItem(product.id);
      }
    }
  }

  @override
  Future<void> updateQuantity(Product product, int quantity) async {
    if (quantity <= 0) {
      await localDataSource.removeItem(product.id);
    } else {
      await localDataSource.updateQuantity(product.id, quantity);
    }
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.clearCart();
  }
}
