import 'package:sqflite/sqflite.dart';
import '../../../../core/db/db_helper.dart';
import 'order_item_model.dart';
import 'order_model.dart';

class LocalDataSource {
  final Future<Database> _dbFuture = DatabaseHelper().database;

  Future<void> insertOrder(OrderModel order) async {
    final db = await _dbFuture;
    await db.insert('orders', order.toJson());

    for (final item in order.items) {
      final itemModel = item as OrderItemModel;
      await db.insert('order_items', itemModel.toJson(order.id));
    }
  }

  Future<List<OrderModel>> getOrders() async {
    final db = await _dbFuture;
    final orderMaps = await db.query('orders');
    List<OrderModel> orders = [];

    for (final orderMap in orderMaps) {
      final orderId = orderMap['id'] as String;
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      final items = itemMaps.map((i) => OrderItemModel.fromJson(i)).toList();
      orders.add(OrderModel.fromJson(orderMap, items));
    }

    return orders;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await _dbFuture;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await _dbFuture;
    final orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (orderMaps.isEmpty) return null;

    final itemMaps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    final items = itemMaps.map((e) => OrderItemModel.fromJson(e)).toList();

    return OrderModel.fromJson(orderMaps.first, items);
  }
}
