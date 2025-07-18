import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/stock.dart';
import 'repo.dart';

class GetAllStockEntries {
  final StockEntryRepo repo;

  GetAllStockEntries(this.repo);

  Future<Either<Failure, List<StockEntry>>> call() {
    return repo.getAll();
  }
}

class GetStockEntryById {
  final StockEntryRepo repo;
  GetStockEntryById(this.repo);

  Future<Either<Failure, StockEntry>> call(String name) => repo.getById(name);
}

class AddStockEntry {
  final StockEntryRepo repo;
  AddStockEntry(this.repo);

  Future<Either<Failure, void>> call(StockEntry entry) {
    return repo.add(entry);
  }
}

class UpdateStockEntry {
  final StockEntryRepo repo;
  UpdateStockEntry(this.repo);

  Future<Either<Failure, void>> call(StockEntry entry) {
    return repo.update(entry);
  }
}
