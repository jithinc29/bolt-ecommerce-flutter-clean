import 'package:ecommerce_sqlite_clean/core/exception.dart';
import 'package:ecommerce_sqlite_clean/features/products/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/products/data/models/product_model.dart';
import 'package:ecommerce_sqlite_clean/features/products/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/entities/product.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSourceImpl();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
    localDataSource: ref.watch(productLocalDataSourceProvider),
  );
});

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    final repository = ref.watch(productRepositoryProvider);
    return ProductsNotifier(repository);
  },
);

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isOffline;
  final int offset;
  final String? errorMessage;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;

  const ProductsState({
    required this.products,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.isOffline,
    required this.offset,
    this.errorMessage,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
  });

  factory ProductsState.initial() {
    return const ProductsState(
      products: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      isOffline: false,
      offset: 0,
      errorMessage: null,
      searchQuery: null,
      minPrice: null,
      maxPrice: null,
    );
  }

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isOffline,
    int? offset,
    String? errorMessage,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    bool clearSearchQuery = false,
    bool clearPriceFilter = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      offset: offset ?? this.offset,
      errorMessage: errorMessage,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      minPrice: clearPriceFilter ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceFilter ? null : (maxPrice ?? this.maxPrice),
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository repository;
  final int _limit = 10;

  ProductsNotifier(this.repository) : super(ProductsState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await repository.getProducts(
        offset: 0,
        limit: _limit,
        title: state.searchQuery,
        priceMin: state.minPrice,
        priceMax: state.maxPrice,
      );

      state = state.copyWith(
        products: products,
        isLoading: false,
        offset: _limit,
        hasMore: products.length >= _limit,
        isOffline: false,
      );
    } on NetworkException catch (e) {
      // Try local cache
      try {
        final localProducts = await repository.getAllLocalProducts();
        if (localProducts.isNotEmpty) {
          state = state.copyWith(
            products: localProducts,
            isLoading: false,
            // Assuming we loaded everything locally or just initial batch?
            // User requirement implies logic similar to before.
            // Before: state = AsyncValue.data(localProducts.take(_limit).toList());
            offset: _limit,
            hasMore: localProducts.length > _limit,
            isOffline: true,
            errorMessage: null, // Showing cached content, not error
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isOffline: true,
            errorMessage: e.message,
          );
        }
      } catch (_) {
        state = state.copyWith(
          isLoading: false,
          isOffline: true,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isOffline) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final newProducts = await repository.getProducts(
        offset: state.offset,
        limit: _limit,
        title: state.searchQuery,
        priceMin: state.minPrice,
        priceMax: state.maxPrice,
      );

      if (newProducts.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        state = state.copyWith(
          products: [...state.products, ...newProducts],
          isLoadingMore: false,
          offset: state.offset + _limit,
          hasMore: newProducts.length >= _limit,
        );
      }
    } catch (e) {
      // If error during load more, just stop loading and maybe show snackbar if UI handles it?
      // For now just stop loading
      state = state.copyWith(
        isLoadingMore: false,
        // Optional: errorMessage: e.toString() if we want to show it
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  void updateSearchQuery(String? query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query, offset: 0, products: []);
    loadInitial();
  }

  void updatePriceFilter(double? min, double? max) {
    if (state.minPrice == min && state.maxPrice == max) return;
    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      offset: 0,
      products: [],
    );
    loadInitial();
  }

  void clearSearchAndFilters() {
    if (state.searchQuery == null &&
        state.minPrice == null &&
        state.maxPrice == null) {
      return;
    }
    state = state.copyWith(
      clearSearchQuery: true,
      clearPriceFilter: true,
      offset: 0,
      products: [],
    );
    loadInitial();
  }
}
