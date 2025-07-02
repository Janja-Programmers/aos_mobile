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
      final res = await _client.client.get(STOCK_ENTRY_ENDPOINT);
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
}
