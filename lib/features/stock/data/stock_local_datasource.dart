import 'package:sqflite/sqflite.dart';
import '../../../../core/db/db_helper.dart';
import 'model/stock_entry_model.dart';
import 'model/stock_item_model.dart';

class StockLocalDataSource {
  final Future<Database> _dbFuture = DatabaseHelper().database;

  Future<void> insertStockEntryWithItems(StockEntryModel entry) async {
    final db = await _dbFuture;

    await db.transaction((txn) async {
      final entryId = await txn.insert(
        'stock_entries',
        entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var item in entry.items) {
        await txn.insert(
          'stock_items',
          StockItemModel(
            id: item.id,
            stockEntryId: entryId,
            targetWarehouse: item.targetWarehouse,
            itemCode: item.itemCode,
            quantity: item.quantity,
            itemPrice: item.itemPrice,
          ).toJson(),
        );
      }
    });
  }

  Future<List<StockEntryModel>> getStockEntriesByUser(int userId) async {
    final db = await _dbFuture;

    final entryMaps = await db.query(
      'stock_entries',
      where: 'created_by = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    List<StockEntryModel> entries = [];

    for (var entry in entryMaps) {
      final items = await db.query(
        'stock_items',
        where: 'stock_entry_id = ?',
        whereArgs: [entry['id']],
      );

      entries.add(
        StockEntryModel.fromJson(
          entry,
          items.map((i) => StockItemModel.fromJson(i)).toList(),
        ),
      );
    }

    return entries;
  }

  Future<StockEntryModel?> getStockEntryDetail(int entryId) async {
    final db = await _dbFuture;

    final entryList = await db.query(
      'stock_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );

    if (entryList.isEmpty) return null;

    final items = await db.query(
      'stock_items',
      where: 'stock_entry_id = ?',
      whereArgs: [entryId],
    );

    return StockEntryModel.fromJson(
      entryList.first,
      items.map((i) => StockItemModel.fromJson(i)).toList(),
    );
  }
}
