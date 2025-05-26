import '../cart_repository.dart';

class UpdateCartQuantity {
  final CartRepository repository;

  UpdateCartQuantity(this.repository);

  Future<void> call(String id, int quantity) async {
    if (quantity < 0) {
      throw ArgumentError('Quantity cannot be negative');
    }
    await repository.updateCartQuantity(id, quantity);
  }
}
