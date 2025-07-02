import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';

abstract class StockEntryRepo {
  Future<Either<Failure, List<String>>> getAllNames();
  Future<Either<Failure, StockEntry>> getById(String name);
  Future<Either<Failure, void>> add(StockEntry entry);

  // ✅ New method for updating a Stock Entry
  Future<Either<Failure, void>> update(StockEntry entry);
}
