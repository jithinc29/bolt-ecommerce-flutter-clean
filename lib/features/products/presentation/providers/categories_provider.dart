import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exception.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import 'product_providers.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    remoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
  );
});

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((
      ref,
    ) {
      final repository = ref.watch(categoryRepositoryProvider);
      return CategoriesNotifier(repository);
    });

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository repository;

  CategoriesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await repository.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      if (e is NetworkException) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(NetworkException(e.toString()), stack);
      }
    }
  }
}
