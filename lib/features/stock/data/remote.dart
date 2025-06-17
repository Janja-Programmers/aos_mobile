import 'package:dartz/dartz.dart';

import '/core/constants/const.dart'; 
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class StockEntryRemoteDS {
  final APIClient _client;
  StockEntryRemoteDS(this._client);

  Future<Either<Failure, List<StockEntryModel>>> getAll() async {
    try {
      // 1️⃣ list endpoint – only names
      final res = await _client.client.get(STOCK_ENTRY_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      // 2️⃣ fetch full records in parallel
      final futures =
          list
              .map(
                (e) => _client.client.get('$STOCK_ENTRY_ENDPOINT/${e['name']}'),
              )
              .toList();
      final responses = await Future.wait(futures);

      // 3️⃣ map → model
      final models =
          responses
              .map((r) => StockEntryModel.fromJson(r.data['data']))
              .toList();

      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
