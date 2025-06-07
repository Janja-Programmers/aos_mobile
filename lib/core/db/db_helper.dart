import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _dbName = 'mall.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE items (
      item_code TEXT PRIMARY KEY,
      item_name TEXT UNIQUE NOT NULL,
      item_group TEXT NOT NULL,
      company TEXT NOT NULL,
      created_by INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE stock_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      company TEXT NOT NULL,
      stock_entry_type TEXT NOT NULL,
      target_warehouse TEXT NOT NULL,
      created_by INTEGER NOT NULL,
      FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE stock_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stock_entry_id INTEGER NOT NULL,
      target_warehouse TEXT NOT NULL,
      item_code TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      item_price REAL NOT NULL,
      FOREIGN KEY (stock_entry_id) REFERENCES stock_entries(id) ON DELETE CASCADE,
      FOREIGN KEY (item_code) REFERENCES items(item_code) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE website_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      website_display_name TEXT NOT NULL,
      item_code TEXT NOT NULL,
      is_published INTEGER NOT NULL,
      images TEXT,
      video TEXT,
      short_description TEXT,
      full_description TEXT,
      created_by INTEGER NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');

    // 🔥 Add cart_items table
    await db.execute('''
    CREATE TABLE cart_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_code TEXT NOT NULL UNIQUE,
      quantity INTEGER NOT NULL
    )
  ''');

    // 🔥 Add orders table
    await db.execute('''
    CREATE TABLE orders (
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      customer_name TEXT NOT NULL,
      order_type TEXT NOT NULL DEFAULT 'Sales',
      order_date TEXT NOT NULL,
      company TEXT NOT NULL DEFAULT 'Ownashop',
      grand_total REAL NOT NULL,
      shipping_address TEXT NOT NULL,
      contact_name TEXT NOT NULL,
      contact_mobile TEXT NOT NULL,
      contact_email TEXT NOT NULL,
      status TEXT NOT NULL
    )
  ''');

    // 🔥 Add order_items table
    await db.execute('''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id TEXT NOT NULL,
      sno INTEGER NOT NULL,
      item_id TEXT NOT NULL,
      item_name TEXT NOT NULL,
      delivery_date TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      rate REAL NOT NULL,
      amount REAL NOT NULL,
      FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )
  ''');
  }
}
