import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/entity/stock.dart';
import '../domain/repo.dart';

import 'models/stock.dart';
import 'remote.dart';

class StockEntryRepoImpl implements StockEntryRepo {
  final StockEntryRemoteDS remoteDS;

  StockEntryRepoImpl(this.remoteDS);

  @override
  Future<Either<Failure, List<StockEntry>>> getAll() {
    return remoteDS.getAll();
  }

  @override
  Future<Either<Failure, StockEntry>> getById(String name) async {
    final result = await remoteDS.getById(name);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, void>> add(StockEntry entry) {
    final model = StockEntryModel.fromEntity(entry);
    return remoteDS.add(model);
  }

  @override
  Future<Either<Failure, void>> update(StockEntry entry) {
    final model = StockEntryModel.fromEntity(entry);
    return remoteDS.update(model);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    await remoteDS.deleteEntry(id);
    return right(null);
  }
}
