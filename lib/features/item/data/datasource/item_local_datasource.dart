import 'package:sqflite/sqflite.dart';
import '../../../../core/db/db_helper.dart';
import '../item_model.dart';

class ItemLocalDataSource {
  late final Future<Database> _dbFuture;

  ItemLocalDataSource() {
    _dbFuture = DatabaseHelper().database;
  }

  Future<void> insertItem(ItemModel item) async {
    final db = await _dbFuture;
    await db.insert(
      'items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ItemModel>> getItemsByUser(int userId) async {
    final db = await _dbFuture;
    final maps = await db.query(
      'items',
      where: 'created_by = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => ItemModel.fromJson(map)).toList();
  }

  Future<List<ItemModel>> getAllItems() async {
    final db = await _dbFuture;
    final maps = await db.query('items');

    return maps.map((map) => ItemModel.fromJson(map)).toList();
  }
}
