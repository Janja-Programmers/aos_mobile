import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';

abstract class StockEntryRepo {
  Future<Either<Failure, List<StockEntry>>> getAll();
  Future<Either<Failure, StockEntry>> getById(String name);

  /// Create a new draft → returns created StockEntry (with ID)
  Future<Either<Failure, StockEntry>> add(StockEntry entry);

  /// Update draft or submit → returns updated StockEntry
  Future<Either<Failure, StockEntry>> update(StockEntry entry);

  /// Delete still can return void
  Future<Either<Failure, void>> delete(String id);
}
