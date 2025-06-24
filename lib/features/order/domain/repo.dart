import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'sales_order.dart';

abstract class SalesOrderRepo {
  Future<Either<Failure, List<SalesOrder>>> getAll();
  Future<Either<Failure, Unit>> placeOrder(OrderPayload payload);
}
