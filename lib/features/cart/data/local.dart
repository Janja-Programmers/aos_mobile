import 'package:sqflite/sqflite.dart';

import '/core/db/db_helper.dart';
import 'model.dart';

class CartLocalDataSource {
  final dbHelper = DatabaseHelper();

  Future<void> insert(CartItemModel item) async {
    final db = await dbHelper.database;
    await db.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItemModel>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query('cart');
    return maps.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<void> delete(String code) async {
    final db = await dbHelper.database;
    await db.delete('cart', where: 'code = ?', whereArgs: [code]);
  }

  Future<void> clear() async {
    final db = await dbHelper.database;
    await db.delete('cart');
  }

  Future<void> updateQuantity(String code, int quantity) async {
    final db = await dbHelper.database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}
