import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class ItemPriceRemoteDS {
  final APIClient _client;

  ItemPriceRemoteDS(this._client);

  Future<Either<Failure, List<ItemPriceModel>>> getAll() async {
    try {
      // 1️⃣ List endpoint returns only name
      final res = await _client.client.get(ITEM_PRICE_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      // 2️⃣ Fetch full details in parallel
      final futures =
          list
              .map(
                (e) => _client.client.get('$ITEM_PRICE_ENDPOINT/${e['name']}'),
              )
              .toList();

      final responses = await Future.wait(futures);

      // 3️⃣ Map each response to model
      final models =
          responses
              .map((resp) => ItemPriceModel.fromJson(resp.data['data']))
              .toList();

      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, ItemPriceModel>> create(ItemPriceModel model) async {
    try {
      final res = await _client.client.post(
        ITEM_PRICE_ENDPOINT,
        data: {'data': model.toJson()},
      );
      return Right(ItemPriceModel.fromJson(res.data['data']));
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
