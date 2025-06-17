import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'repo.dart';
import 'sales_order.dart';

class GetAllSalesOrders {
  final SalesOrderRepo repo;

  GetAllSalesOrders(this.repo);

  Future<Either<Failure, List<SalesOrder>>> call() => repo.getAll();
}
