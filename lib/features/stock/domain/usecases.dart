import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'stock_entry.dart';
import 'repo.dart';

class GetAllStockEntries {
  final StockEntryRepo repo;
  GetAllStockEntries(this.repo);

  Future<Either<Failure, List<StockEntry>>> call() => repo.getAll();
}
