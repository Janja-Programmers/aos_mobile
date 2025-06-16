import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import '../domain/webitem.dart';

import 'model.dart';

class WebsiteRemoteDataSource {
  final APIClient _client;

  WebsiteRemoteDataSource(this._client);

  Future<Either<Failure, List<WebsiteItem>>> fetchItems() async {
    try {
      final res = await _client.client.get(WEB_ITEM_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      final futures =
          list
              .map(
                (item) =>
                    _client.client.get('$WEB_ITEM_ENDPOINT/${item['name']}'),
              )
              .toList();

      final responses = await Future.wait(futures);

      final items =
          responses.map((resp) {
            final model = WebsiteItemModel.fromJson(resp.data['data']);
            return model.toEntity();
          }).toList();

      return Right(items);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ----------------- CREATE -----------------
  Future<Either<Failure, WebsiteItem>> createItem(WebsiteItem entity) async {
    try {
      final model = WebsiteItemModel.fromEntity(entity);
      final res = await _client.client.post(
        WEB_ITEM_ENDPOINT,
        data: model.toJson(),
      );
      final created = WebsiteItemModel.fromJson(res.data['data']).toEntity();
      return Right(created);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ----------------- UPDATE -----------------
  Future<Either<Failure, WebsiteItem>> updateItem(
    String id,
    WebsiteItem entity,
  ) async {
    try {
      final model = WebsiteItemModel.fromEntity(entity);
      final res = await _client.client.put(
        '$WEB_ITEM_ENDPOINT/$id',
        data: model.toJson(),
      );
      final updated = WebsiteItemModel.fromJson(res.data['data']).toEntity();
      return Right(updated);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
