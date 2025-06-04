import '../order.dart';
import '../order_repo.dart';

class CompleteOrder {
  final OrderRepository repository;

  CompleteOrder(this.repository);

  Future<void> call(String orderId) async {
    await repository.updateOrderStatus(orderId, OrderStatus.completed);
  }
}
