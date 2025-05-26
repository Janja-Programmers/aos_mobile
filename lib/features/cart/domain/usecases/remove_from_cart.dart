import '../cart_repository.dart';

class RemoveFromCart {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  Future<void> call(String id) async {
    await repository.removeFromCart(id);
  }
}
