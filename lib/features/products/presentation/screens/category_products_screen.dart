import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_sqlite_clean/features/products/domain/entities/category.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/providers/category_products_provider.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/search_filter_widget.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(categoryProductsProvider(widget.category.id).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(
      categoryProductsProvider(widget.category.id).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: Consumer(
              builder: (context, ref, child) {
                final cartState = ref.watch(cartProvider);
                return Badge(
                  label: Text('${cartState.totalItems}'),
                  isLabelVisible: cartState.totalItems > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: Stack(
          children: [
            // Aesthetic Background Gradient
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.deepPurple.shade50.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final isOffline = ref.watch(
                      categoryProductsProvider(
                        widget.category.id,
                      ).select((s) => s.isOffline),
                    );
                    if (!isOffline) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange.shade100,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You\'re offline. Showing cached products.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(
                      categoryProductsProvider(widget.category.id),
                    );
                    return SearchFilterWidget(
                      initialSearch: state.searchQuery,
                      minPrice: state.minPrice,
                      maxPrice: state.maxPrice,
                      onSearchChanged: (query) => ref
                          .read(
                            categoryProductsProvider(
                              widget.category.id,
                            ).notifier,
                          )
                          .updateSearchQuery(query),
                      onFilterApplied: (min, max) => ref
                          .read(
                            categoryProductsProvider(
                              widget.category.id,
                            ).notifier,
                          )
                          .updatePriceFilter(min, max),
                    );
                  },
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(
                        categoryProductsProvider(widget.category.id),
                      );
                      final notifier = ref.read(
                        categoryProductsProvider(widget.category.id).notifier,
                      );

                      if (state.isLoading && state.products.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.errorMessage != null &&
                          state.products.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.errorMessage ?? 'Something went wrong',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pull down to refresh or try again later',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => notifier.loadInitial(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state.products.isEmpty) {
                        return const Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount:
                            state.products.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.products.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final product = state.products[index];
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Hero(
                                        tag: 'product_${product.id}',
                                        child: CachedNetworkImage(
                                          imageUrl: product.imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.grey[200],
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${product.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
