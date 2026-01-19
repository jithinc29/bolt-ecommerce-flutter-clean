import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/screens/product_details_screen.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/widgets/categories_widget.dart';
import 'package:ecommerce_sqlite_clean/features/payment/presentation/screens/payment_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/screens/cart_screen.dart';
import '../providers/product_providers.dart';

import '../widgets/search_filter_widget.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
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
    // Load more when scrolled to bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(productsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isOffline = ref.watch(
                productsProvider.select((s) => s.isOffline),
              );
              if (!isOffline) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Colors.orange.shade900,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
          ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
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
                      productsProvider.select((s) => s.isOffline),
                    );
                    if (!isOffline) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange.shade100,
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.orange.shade900,
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

                const CategoriesWidget(),

                Consumer(
                  builder: (context, ref, child) {
                    final searchQuery = ref.watch(
                      productsProvider.select((s) => s.searchQuery),
                    );
                    final minPrice = ref.watch(
                      productsProvider.select((s) => s.minPrice),
                    );
                    final maxPrice = ref.watch(
                      productsProvider.select((s) => s.maxPrice),
                    );
                    return SearchFilterWidget(
                      initialSearch: searchQuery,
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      onSearchChanged: (query) => ref
                          .read(productsProvider.notifier)
                          .updateSearchQuery(query),
                      onFilterApplied: (min, max) => ref
                          .read(productsProvider.notifier)
                          .updatePriceFilter(min, max),
                    );
                  },
                ),

                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(productsProvider);
                      final notifier = ref.read(productsProvider.notifier);

                      if (state.isLoading && state.products.isEmpty) {
                        return _buildShimmerLoading();
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
                                          const SizedBox(height: 4),
                                          Text(
                                            product.category,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
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
                                              GestureDetector(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .addToCart(product);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).clearSnackBars();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Added ${product.name} to cart',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Container(width: 60, height: 60, color: Colors.white),
              title: Container(height: 16, color: Colors.white),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(height: 12, width: 100, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 60, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
