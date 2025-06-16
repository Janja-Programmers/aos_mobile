import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import '../domain/entity.dart';
import 'model.dart';

class ItemRemoteDataSource {
  final APIClient _client;
  ItemRemoteDataSource(this._client);

  // ───────────────────────────────── fetch ALL ─────────────────────────────────
  Future<Either<Failure, List<Item>>> fetchItems() async {
    try {
      // 1️⃣ list endpoint – only names
      final res = await _client.client.get(ITEM_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      // 2️⃣ fetch each full record in parallel
      final futures =
          list
              .map((e) => _client.client.get('$ITEM_ENDPOINT/${e['name']}'))
              .toList();
      final responses = await Future.wait(futures);

      // 3️⃣ map → model → entity
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

  // ───────────────────────────────── fetch ONE ─────────────────────────────────
  Future<Either<Failure, Item>> fetchItemByName(String name) async {
    try {
      final res = await _client.client.get('$ITEM_ENDPOINT/$name');
      final model = ItemModel.fromJson(res.data['data']);
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ───────────────────────────────── create ───────────────────────────────────
  Future<Either<Failure, Item>> createItem(Item entity) async {
    try {
      final model = ItemModel.fromEntity(entity);
      final res = await _client.client.post(
        ITEM_ENDPOINT,
        data: model.toJson(),
      );
      final created = ItemModel.fromJson(res.data['data']).toEntity();
      return Right(created);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ───────────────────────────────── update ───────────────────────────────────
  Future<Either<Failure, Item>> updateItem(Item entity) async {
    try {
      final model = ItemModel.fromEntity(entity);
      final res = await _client.client.put(
        '$ITEM_ENDPOINT/${entity.name}',
        data: model.toJson(),
      );
      final updated = ItemModel.fromJson(res.data['data']).toEntity();
      return Right(updated);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
