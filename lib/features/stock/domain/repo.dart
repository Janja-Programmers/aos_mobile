// lib/features/stock_entry/domain/stock_entry_repo.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import 'stock_entry.dart';

abstract class StockEntryRepo {
  Future<Either<Failure, List<StockEntry>>> getAll();
}
