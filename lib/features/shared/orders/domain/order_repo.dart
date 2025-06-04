import 'order.dart';

abstract class OrderRepository {
  Future<void> createOrder(Order order);
  Future<List<Order>> getOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<Order?> getOrderById(String orderId);
}
