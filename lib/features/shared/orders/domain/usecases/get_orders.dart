import '../order.dart';
import '../order_repo.dart';

class GetOrders {
  final OrderRepository repository;

  GetOrders(this.repository);

  Future<List<Order>> call() async {
    return await repository.getOrders();
  }
}
