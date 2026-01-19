import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> saveProducts(List<ProductModel> products);
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int offset = 0,
    int limit = 10,
  });
  Future<ProductModel?> getProduct(int id);
  Future<void> clearProducts();
  Future<int> getProductCount();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/products.db'; // Alternative to join()
    // Or use: final path = join(dbPath, 'products.db'); with import 'package:path/path.dart';

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            imageUrl TEXT NOT NULL,
            images TEXT NOT NULL,
            category TEXT NOT NULL,
            categoryId INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('''
            CREATE TABLE products(
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              price REAL NOT NULL,
              imageUrl TEXT NOT NULL,
              images TEXT NOT NULL,
              category TEXT NOT NULL,
              categoryId INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    final db = await database;
    final batch = db.batch();

    for (final product in products) {
      batch.insert(
        'products',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'id ASC',
    );

    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int offset = 0,
    int limit = 10,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'id ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<ProductModel?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  @override
  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }

  @override
  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
