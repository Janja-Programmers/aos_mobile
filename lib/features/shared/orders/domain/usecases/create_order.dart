import '../order.dart';
import '../order_repo.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<void> call(Order order) async {
    await repository.createOrder(order);
  }
}
