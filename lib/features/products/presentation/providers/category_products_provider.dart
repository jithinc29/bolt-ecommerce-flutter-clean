import 'package:ecommerce_sqlite_clean/core/exception.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Family provider to handle state for each category
final categoryProductsProvider = StateNotifierProvider.family
    .autoDispose<CategoryProductsNotifier, ProductsState, int>((
      ref,
      categoryId,
    ) {
      final repository = ref.watch(productRepositoryProvider);
      return CategoryProductsNotifier(repository, categoryId);
    });

class CategoryProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository repository;
  final int categoryId;
  final int _limit = 10;

  CategoryProductsNotifier(this.repository, this.categoryId)
    : super(ProductsState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await repository.getProductsByCategory(
        categoryId,
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
      state = state.copyWith(
        isLoading: false,
        isOffline: true,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isOffline) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final newProducts = await repository.getProductsByCategory(
        categoryId,
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
      state = state.copyWith(isLoadingMore: false);
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
}
