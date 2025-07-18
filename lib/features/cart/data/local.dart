import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '/core/db/db_helper.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '../domain/cart.dart';
import 'model.dart';

class CartLocalDataSource {
  final DatabaseHelper dbHelper;

  CartLocalDataSource(this.dbHelper);

  Future<Either<Failure, CartItem>> insert(CartItem item) async {
    try {
      final db = await dbHelper.database;
      final model = CartItemModel.fromEntity(item);

      await db.insert(
        'cart',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Right(item);
    } catch (e) {
      return Left(handleException('Failed to insert item: $e'));
    }
  }

  Future<Either<Failure, List<CartItem>>> getAll() async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query('cart');
      final items =
          maps.map((e) => CartItemModel.fromMap(e).toEntity()).toList();

      return Right(items);
    } catch (e) {
      return Left(handleException('Failed to get cart items: $e'));
    }
  }

  Future<Either<Failure, void>> delete(String code) async {
    try {
      final db = await dbHelper.database;
      await db.delete('cart', where: 'code = ?', whereArgs: [code]);
      return const Right(null);
    } catch (e) {
      return Left(handleException('Failed to delete item: $e'));
    }
  }

  Future<Either<Failure, void>> clear() async {
    try {
      final db = await dbHelper.database;
      await db.delete('cart');
      return const Right(null);
    } catch (e) {
      return Left(handleException('Failed to clear cart: $e'));
    }
  }

  Future<Either<Failure, void>> updateQuantity(
    String code,
    int quantity,
  ) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'cart',
        {'quantity': quantity},
        where: 'code = ?',
        whereArgs: [code],
      );
      return const Right(null);
    } catch (e) {
      return Left(handleException('Failed to update quantity: $e'));
    }
  }
}
