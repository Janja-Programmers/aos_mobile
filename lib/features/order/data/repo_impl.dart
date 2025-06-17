import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/repo.dart';
import '../domain/sales_order.dart';

import 'remote.dart';

class SalesOrderRepoImpl implements SalesOrderRepo {
  final SalesOrderRemoteDS remote;

  SalesOrderRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<SalesOrder>>> getAll() async {
    final result = await remote.getAll();
    return result.map((models) => models.cast<SalesOrder>());
  }
}
