import 'package:dartz/dartz.dart';

import '/core/utils/api_client.dart';

import '/core/utils/logger.dart';
import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';

import 'model.dart';

class CartRemoteDataSource {
  final APIClient client;

  CartRemoteDataSource(this.client);

  Future<Either<Failure, Unit>> updateCartItem(CartItemModel model) async {
    try {
      appLogger.i("✅ API data ${model.toJson()}");

      final res = await client.client.post(
        ADD_CART_ENDPOINT,
        data: model.toJson(),
      );

      // Log response (optional)
      appLogger.i("✅ API Response: ${res.data}");

      return const Right(unit);
    } catch (e) {
      appLogger.e("❌ Error updating cart item: $e");
      return Left(handleException(e));
    }
  }
}
