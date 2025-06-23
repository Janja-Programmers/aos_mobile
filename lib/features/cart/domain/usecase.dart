import 'cart.dart';
import 'repo.dart';

class AddToCartUseCase {
  final CartRepo repo;
  AddToCartUseCase(this.repo);
  Future<void> call(CartItem item) => repo.addItem(item);
}

class GetCartItemsUseCase {
  final CartRepo repo;
  GetCartItemsUseCase(this.repo);
  Future<List<CartItem>> call() => repo.getItems();
}

class RemoveFromCartUseCase {
  final CartRepo repo;
  RemoveFromCartUseCase(this.repo);
  Future<void> call(String code) => repo.removeItem(code);
}

class ClearCartUseCase {
  final CartRepo repo;
  ClearCartUseCase(this.repo);
  Future<void> call() => repo.clearCart();
}

class UpdateCartItemQuantityUseCase {
  final CartRepo repo;
  UpdateCartItemQuantityUseCase(this.repo);
  Future<void> call(String code, int quantity) =>
      repo.updateQuantity(code, quantity);
}
