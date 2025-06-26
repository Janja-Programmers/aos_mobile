import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ownashop/core/utils/logger.dart';

import '../../../core/errors/exception.dart';
import '/core/errors/failures.dart';

import '../domain/repo.dart';
import '../domain/sales_order.dart';

import 'model.dart';
import 'remote.dart';

class SalesOrderRepoImpl implements SalesOrderRepo {
  final SalesOrderRemoteDS remote;
  final SalesOrderPayloadRemoteDS payloadRemote;

  SalesOrderRepoImpl({required this.remote, required this.payloadRemote});

  @override
  Future<Either<Failure, List<SalesOrder>>> getAll() async {
    final result = await remote.getAll();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Unit>> placeOrder(OrderPayload payload) async {
    try {
      appLogger.i(
        'Placing order with payload: ${payload.toJson()} from REPO_IMPL',
      );

      print("🧪 payload.customer = ${payload.customer}");
      print("🧪 payload.deliveryDate = ${payload.deliveryDate}");
      print("🧪 payload.items = ${payload.items.length}");
      print("🧪 payload.shippingAddressName = ${payload.shippingAddressName}");
      final model = OrderPayloadModel.fromEntity(payload);

      print(
        "📦 SalesOrderRepoImpl sending OrderPayload: ${jsonEncode(model.toJson())}",
      );

      return await payloadRemote.placeOrder(model);
    } catch (e, stack) {
      print("❌ Exception while building payload model: $e");
      print(stack);
      return Left(handleException(e));
    }
  }
}
