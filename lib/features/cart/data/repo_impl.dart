import 'package:dartz/dartz.dart';
import 'package:ownashop/core/errors/failures.dart';
import 'package:ownashop/core/errors/exception.dart';

import '../domain/cart.dart';
import '../domain/repo.dart';
import 'local.dart';
import 'model.dart';

class CartRepoImpl implements CartRepo {
  final CartLocalDataSource local;
  CartRepoImpl(this.local);

  @override
  Future<Either<Failure, List<CartItem>>> addItem(CartItem item) async {
    try {
      final model = CartItemModel.fromEntity(item);
      return await local
          .insert(model)
          .then(
            (result) =>
                result.fold((failure) => Left(failure), (_) => local.getAll()),
          );
    } catch (e) {
      return Left(handleException('Failed to add item: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getItems() async {
    try {
      return await local.getAll();
    } catch (e) {
      return Left(handleException('Failed to load cart items: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeItem(String code) async {
    try {
      await local.delete(code);
      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to remove item: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await local.clear();
      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to clear cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateQuantity(
    String code,
    int quantity,
  ) async {
    try {
      await local.updateQuantity(code, quantity);
      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to update quantity: $e'));
    }
  }
}
