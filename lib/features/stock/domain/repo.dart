import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';

abstract class StockEntryRepo {
  Future<Either<Failure, List<String>>> getAllNames();
  Future<Either<Failure, StockEntry>> getById(String name);
}
