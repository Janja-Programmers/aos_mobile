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
  Future<Either<Failure, List<StockEntry>>> getAll() async {
    final result = await remoteDS.getAll();
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, StockEntry>> getById(String name) async {
    final result = await remoteDS.getById(name);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, StockEntry>> add(StockEntry entry) async {
    final model = StockEntryModel.fromEntity(entry);
    final result = await remoteDS.add(model);
    return result.map((m) => m.toEntity());
  }

  @override
  Future<Either<Failure, StockEntry>> update(StockEntry entry) async {
    final model = StockEntryModel.fromEntity(entry);
    final result = await remoteDS.update(model);
    return result.map((m) => m.toEntity());
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    await remoteDS.deleteEntry(id);
    return right(null);
  }
}
