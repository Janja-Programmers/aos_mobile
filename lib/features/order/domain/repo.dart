import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'sales_order.dart';

abstract class SalesOrderRepo {
  Future<Either<Failure, List<SalesOrder>>> getAll();
  Future<Either<Failure, Unit>> placeOrder(OrderPayload payload);

  // NEW: Get order by ID
  Future<Either<Failure, SalesOrder>> getById(String id);

  // NEW: Mark as Delivered
  Future<Either<Failure, Unit>> markAsDelivered(String id);

  // NEW: Mark as Billed
  Future<Either<Failure, Unit>> markAsBilled(String id);
}
