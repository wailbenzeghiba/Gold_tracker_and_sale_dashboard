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
    String path = join(await getDatabasesPath(), 'metal_inventory.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add the onUpgrade method
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
        sell_price REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE inventory ADD COLUMN quantity INTEGER');
      await db.execute('ALTER TABLE inventory ADD COLUMN sell_price REAL');
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
}