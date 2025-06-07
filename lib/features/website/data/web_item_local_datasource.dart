import 'package:ownashop/features/website/domain/website_item.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/db/db_helper.dart';
import 'website_item_model.dart';

abstract class WebsiteItemLocalDatasource {
  Future<void> addWebsiteItem(WebsiteItemModel item);
  Future<List<WebsiteItemModel>> getAllWebsiteItems();
  Future<WebsiteItem> getWebsiteItemByCode(String itemCode);
}

class WebsiteItemLocalDatasourceImpl implements WebsiteItemLocalDatasource {
  final DatabaseHelper _dbHelper;

  WebsiteItemLocalDatasourceImpl() : _dbHelper = DatabaseHelper();

  @override
  Future<void> addWebsiteItem(WebsiteItemModel item) async {
    final db = await _dbHelper.database;
    await db.insert(
      'website_items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<WebsiteItemModel>> getAllWebsiteItems() async {
    final db = await _dbHelper.database;
    final result = await db.query('website_items', orderBy: 'id DESC');
    return result.map((e) => WebsiteItemModel.fromJson(e)).toList();
  }

  @override
  Future<WebsiteItem> getWebsiteItemByCode(String itemCode) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'website_items',
      where: 'itemCode = ?',
      whereArgs: [itemCode],
    );
    if (result.isNotEmpty) {
      final websiteItemModel = WebsiteItemModel.fromJson(result.first);
      return websiteItemModel;
    } else {
      throw Exception('Item not found');
    }
  }
}
