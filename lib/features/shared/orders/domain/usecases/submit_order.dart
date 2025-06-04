import '../order.dart';
import '../order_repo.dart';

class SubmitOrder {
  final OrderRepository repository;

  SubmitOrder(this.repository);

  Future<void> call(String orderId) async {
    await repository.updateOrderStatus(orderId, OrderStatus.submitted);
  }
}
