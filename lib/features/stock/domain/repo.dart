import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';

abstract class StockEntryRepo {
  Future<Either<Failure, List<StockEntry>>> getAll();
  Future<Either<Failure, StockEntry>> getById(String name);
  Future<Either<Failure, void>> add(StockEntry entry);
  Future<Either<Failure, void>> update(StockEntry entry);
}
