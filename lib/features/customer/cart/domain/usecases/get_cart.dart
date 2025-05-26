import '../cart_item.dart';
import '../cart_repository.dart';

class GetCart {
  final CartRepository repository;

  GetCart(this.repository);

  Future<List<CartItem>> call() async {
    return await repository.getCartItems();
  }
}
