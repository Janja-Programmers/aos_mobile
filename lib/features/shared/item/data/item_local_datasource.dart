import 'package:amani_mall/core/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'item_model.dart';

abstract class ItemLocalDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel?> getItemByName(String itemName);
  Future<void> insertItem(ItemModel item);
  Future<void> updateItem(String itemName, ItemModel item);
  Future<void> deleteItem(String itemName);
}

class ItemLocalDataSourceImpl implements ItemLocalDataSource {
  late final Future<Database> _dbFuture;

  ItemLocalDataSourceImpl() {
    _dbFuture = DatabaseHelper().database;
  }

  @override
  Future<List<ItemModel>> getItems() async {
    final db = await _dbFuture;
    final List<Map<String, dynamic>> result = await db.query('items');
    return result.map((json) => ItemModel.fromJson(json)).toList();
  }

  @override
  Future<ItemModel?> getItemByName(String itemName) async {
    final db = await _dbFuture;
    final result = await db.query(
      'items',
      where: 'item_name = ?',
      whereArgs: [itemName],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return ItemModel.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<void> insertItem(ItemModel item) async {
    final db = await _dbFuture;
    await db.insert(
      'items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateItem(String itemName, ItemModel item) async {
    final db = await _dbFuture;
    await db.update(
      'items',
      item.toJson(),
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  @override
  Future<void> deleteItem(String itemName) async {
    final db = await _dbFuture;
    await db.delete('items', where: 'item_name = ?', whereArgs: [itemName]);
  }
}
