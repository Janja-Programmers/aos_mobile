import '../domain/order.dart';
import '../domain/order_repo.dart';
import 'local_order_datasource.dart';
import 'order_item_model.dart';
import 'order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final LocalDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<void> createOrder(Order order) async {
    final model = OrderModel(
      id: order.id,
      customerId: order.customerId,
      customerName: order.customerName,
      orderType: order.orderType,
      orderDate: order.orderDate,
      company: order.company,
      items:
          order.items
              .map(
                (e) => OrderItemModel(
                  sno: e.sno,
                  itemId: e.itemId,
                  name: e.name,
                  deliveryDate: e.deliveryDate,
                  quantity: e.quantity,
                  rate: e.rate,
                ),
              )
              .toList(),
      shippingAddress: order.shippingAddress,
      contactName: order.contactName,
      contactMobile: order.contactMobile,
      contactEmail: order.contactEmail,
      status: order.status,
    );
    await localDataSource.insertOrder(model);
  }

  @override
  Future<List<Order>> getOrders() async {
    return await localDataSource.getOrders();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await localDataSource.updateOrderStatus(orderId, status.name);
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    return await localDataSource.getOrderById(orderId);
  }
}
