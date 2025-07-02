// ignore: unused_import
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
  Future<Either<Failure, SalesOrder>> getById(String id) async {
    final result = await remote.getById(id);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> markAsDelivered(String id) {
    return remote.markAsDelivered(id);
  }

  @override
  Future<Either<Failure, Unit>> markAsBilled(String id) {
    return remote.markAsBilled(id);
  }

  @override
  Future<Either<Failure, Unit>> placeOrder(OrderPayload payload) async {
    try {
      appLogger.i(
        'Placing order with payload: ${payload.toJson()} from REPO_IMPL',
      );

      final model = OrderPayloadModel.fromEntity(payload);

      return await payloadRemote.placeOrder(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
