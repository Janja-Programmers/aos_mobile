import 'package:dartz/dartz.dart';

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
    final model = OrderPayloadModel.fromEntity(payload);
    return await payloadRemote.placeOrder(model);
  }
}
