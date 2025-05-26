import '../cart_item.dart';
import '../cart_repository.dart';

class AddToCart {
  final CartRepository repository;

  AddToCart(this.repository);

  Future<void> call(CartItem item) async {
    await repository.addToCart(item);
  }
}
