import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import 'models/stock.dart';

class StockEntryRemoteDS {
  final APIClient _client;

  StockEntryRemoteDS(this._client);

  Future<Either<Failure, List<String>>> getAllNames() async {
    try {
      final res = await _client.client.get(
        STOCK_ENTRY_ENDPOINT,
        queryParameters: {'order_by': 'creation desc'},
      );
      final List<dynamic> list = res.data['data'];
      final names = list.map((e) => e['name'] as String).toList();
      return Right(names);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, StockEntryModel>> getById(String name) async {
    try {
      final res = await _client.client.get('$STOCK_ENTRY_ENDPOINT/$name');
      final model = StockEntryModel.fromJson(res.data['data']);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> add(StockEntryModel entry) async {
    try {
      await _client.client.post(STOCK_ENTRY_ENDPOINT, data: entry.toJson());
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> update(StockEntryModel entry) async {
    try {
      final id = entry.id;
      if (id.isEmpty) {
        return Left(handleException('Missing Stock Entry ID for update.'));
      }

      await _client.client.put(
        '$STOCK_ENTRY_ENDPOINT/$id',
        data: entry.toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
