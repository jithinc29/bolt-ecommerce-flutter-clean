import 'package:sqflite/sqflite.dart';
import 'package:ecommerce_sqlite_clean/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addItem(CartItemModel item);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/cart.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items(
            productId INTEGER PRIMARY KEY,
            quantity INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeItem(int productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}
