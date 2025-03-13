import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 3, // Increase the version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        karat TEXT,
        weight REAL,
        price REAL,
        quantity INTEGER,
        sell_price REAL,
        base_price REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE profit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        net_profit REAL,
        monthly_net_profit REAL,
        yearly_net_profit REAL
      )
    ''');
    await db.insert('profit', {'net_profit': 0.0, 'monthly_net_profit': 0.0, 'yearly_net_profit': 0.0});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(db, 'inventory', 'quantity', 'INTEGER');
      await _addColumnIfNotExists(db, 'inventory', 'sell_price', 'REAL');
      await _addColumnIfNotExists(db, 'inventory', 'base_price', 'REAL');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE profit (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          net_profit REAL,
          monthly_net_profit REAL,
          yearly_net_profit REAL
        )
      ''');
      await db.insert('profit', {'net_profit': 0.0, 'monthly_net_profit': 0.0, 'yearly_net_profit': 0.0});
    }
  }

  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnExists = result.any((column) => column['name'] == columnName);
    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
    }
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await database;
    return await db.insert('inventory', product);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await database;
    return await db.query('inventory');
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    Database db = await database;
    return await db.update(
      'inventory',
      product,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProductQuantity(int id, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await db.delete(
        'inventory',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await db.update(
        'inventory',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<Map<String, dynamic>> getProfit() async {
    Database db = await database;
    final result = await db.query('profit', limit: 1);
    return result.first;
  }

  Future<void> updateProfit(double netProfit, double monthlyNetProfit, double yearlyNetProfit) async {
    Database db = await database;
    await db.update(
      'profit',
      {
        'net_profit': netProfit,
        'monthly_net_profit': monthlyNetProfit,
        'yearly_net_profit': yearlyNetProfit,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}