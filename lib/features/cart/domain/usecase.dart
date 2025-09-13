import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'cart.dart';
import 'repo.dart';

class AddToCartUseCase {
  final CartRepo repo;
  AddToCartUseCase(this.repo);

  Future<Either<Failure, List<CartItem>>> call(CartItem item) {
    return repo.addItem(item);
  }
}

class GetCartItemsUseCase {
  final CartRepo repo;
  GetCartItemsUseCase(this.repo);

  Future<Either<Failure, List<CartItem>>> call() {
    return repo.getItems();
  }
}

class RemoveFromCartUseCase {
  final CartRepo repo;
  RemoveFromCartUseCase(this.repo);

  Future<Either<Failure, Unit>> call(String code) {
    return repo.removeItem(code);
  }
}

class ClearCartUseCase {
  final CartRepo repo;
  ClearCartUseCase(this.repo);

  Future<Either<Failure, Unit>> call() {
    return repo.clearCart();
  }
}

class UpdateCartItemQuantityUseCase {
  final CartRepo repo;
  UpdateCartItemQuantityUseCase(this.repo);

  Future<Either<Failure, Unit>> call(String code, int quantity) {
    return repo.updateQuantity(code, quantity);
  }
}

class UpdateRemoteCartUseCase {
  final CartRepo repo;
  UpdateRemoteCartUseCase(this.repo);

  Future<Either<Failure, Unit>> call(CartItem item) {
    return repo.updateRemoteCart(item);
  }
}
