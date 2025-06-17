import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/stock_entry.dart';
import '../domain/repo.dart';

import 'remote.dart';

class StockEntryRepoImpl implements StockEntryRepo {
  final StockEntryRemoteDS remote;
  StockEntryRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<StockEntry>>> getAll() async {
    final result = await remote.getAll();
    // DTO extends entity → safe cast
    return result.map((models) => models.cast<StockEntry>());
  }
}
