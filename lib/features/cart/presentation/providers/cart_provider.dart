import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_sqlite_clean/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_sqlite_clean/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_sqlite_clean/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/providers/product_providers.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/entities/product.dart';

// Data Source Provider
final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl();
});

// Repository Provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final localDataSource = ref.watch(cartLocalDataSourceProvider);
  final productRepository = ref.watch(productRepositoryProvider);
  return CartRepositoryImpl(
    localDataSource: localDataSource,
    productRepository: productRepository,
  );
});

// State definitions
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    required this.items,
    required this.isLoading,
    this.errorMessage,
  });

  factory CartState.initial() {
    return const CartState(items: [], isLoading: false);
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  double get totalPrice =>
      items.fold(0, (total, item) => total + item.totalPrice);

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);

  bool isInCart(int productId) {
    return items.any((item) => item.product.id == productId);
  }
}

// Notifier
class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(CartState.initial()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load cart',
      );
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      await _repository.addToCart(product);
      await loadCart(); // Refresh state
    } catch (e) {
      // Handling errors silently or could set error message
    }
  }

  Future<void> removeFromCart(Product product) async {
    try {
      await _repository.removeFromCart(product);
      await loadCart();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateQuantity(Product product, int quantity) async {
    try {
      await _repository.updateQuantity(product, quantity);
      await loadCart();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      await loadCart();
    } catch (e) {
      // Handle error
    }
  }
}

// Global Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(repository);
});
