import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';

import 'repo.dart';

class GetAllStockEntryNames {
  final StockEntryRepo repo;
  GetAllStockEntryNames(this.repo);

  Future<Either<Failure, List<String>>> call() => repo.getAllNames();
}

class GetStockEntryById {
  final StockEntryRepo repo;
  GetStockEntryById(this.repo);

  Future<Either<Failure, StockEntry>> call(String name) => repo.getById(name);
}
