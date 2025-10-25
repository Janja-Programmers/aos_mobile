import 'dart:async';
import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/logger.dart';

import '../domain/cart.dart';
import '../domain/repo.dart';

import 'local.dart';
import 'model.dart';
import 'remote.dart';

class CartRepoImpl implements CartRepo {
  final CartLocalDataSource local;
  final CartRemoteDataSource remote;

  CartRepoImpl(this.local, this.remote);

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

  /// 🧩 Update quantity locally + sync remotely
  @override
  Future<Either<Failure, Unit>> updateQuantity(
    String code,
    int quantity,
  ) async {
    try {
      // 1️⃣ Update locally first
      await local.updateQuantity(code, quantity);

      // 2️⃣ Fire & forget remote sync
      unawaited(() async {
        final item = await local.getItemByCode(code);
        if (item != null) {
          final result = await updateRemoteCart(item);
          result.fold(
            (failure) =>
                appLogger.w('Remote sync failed for $code: ${failure.message}'),
            (_) => appLogger.i('Remote sync successful for $code'),
          );
        } else {
          appLogger.w('Item $code not found locally after update');
        }
      }());

      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to update quantity: $e'));
    }
  }

  /// 🔁 Push cart updates to remote
  @override
  Future<Either<Failure, Unit>> updateRemoteCart(CartItem item) async {
    try {
      final model = CartItemModel.fromEntity(item);
      appLogger.i('Syncing cart item to remote: ${model.toJson()}');
      return await remote.updateCartItem(model);
    } catch (e) {
      appLogger.e('Failed to sync cart item', error: e);
      return Left(handleException('Failed to sync cart item'));
    }
  }
}
