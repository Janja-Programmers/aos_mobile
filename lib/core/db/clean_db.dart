import 'db_helper.dart';

Future<void> clearAllTables() async {
  final db = await DatabaseHelper().database;

  await db.delete('users');
  await db.delete('items');
  await db.delete('stock_entries');
  await db.delete('stock_items');
  await db.delete('website_items');
  await db.delete('cart');
  await db.delete('orders');
  await db.delete('order_items');
}
