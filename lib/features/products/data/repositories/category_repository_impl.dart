import '../../../../core/exception.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories() async {
    try {
      final categoryModels = await remoteDataSource.getCategories();
      return categoryModels; // CategoryModel extends Category
    } catch (e) {
      if (e is ServerException) {
        throw NetworkException(e.message);
      } else {
        throw NetworkException('Failed to load categories: $e');
      }
    }
  }
}
