import 'package:sqflite/sqflite.dart';
import '../models/payment_model.dart';

abstract class PaymentLocalDataSource {
  Future<List<PaymentModel>> getPayments();
  Future<void> savePayment(PaymentModel payment);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/payments.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE payments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId TEXT NOT NULL,
            paymentId TEXT,
            amount REAL NOT NULL,
            status TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<PaymentModel>> getPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => PaymentModel.fromMap(map)).toList();
  }

  @override
  Future<void> savePayment(PaymentModel payment) async {
    final db = await database;
    await db.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
