import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'cart.dart';

abstract class CartRepo {
  Future<Either<Failure, List<CartItem>>> getItems();
  Future<Either<Failure, List<CartItem>>> addItem(CartItem item);
  Future<Either<Failure, Unit>> removeItem(String code);
  Future<Either<Failure, Unit>> updateQuantity(String code, int quantity);
  Future<Either<Failure, Unit>> clearCart();

  // 🔄 New: Remote sync
  Future<Either<Failure, Unit>> updateRemoteCart(CartItem item);
}
