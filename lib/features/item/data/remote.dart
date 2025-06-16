import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import '../domain/entity.dart';

import 'model.dart';

class ItemRemoteDataSource {
  final APIClient _client;

  ItemRemoteDataSource(this._client);

  Future<Either<Failure, List<Item>>> fetchItems() async {
    try {
      final res = await _client.client.get(ITEM_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      final futures =
          list
              .map((e) => _client.client.get('$ITEM_ENDPOINT/${e['name']}'))
              .toList();

      final responses = await Future.wait(futures);

      final items =
          responses.map<Item>((resp) {
            final model = ItemModel.fromJson(resp.data['data']);
            return model.toEntity();
          }).toList();

      return Right(items);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
