import 'package:dartz/dartz.dart';
import 'package:ownashop/core/utils/logger.dart';

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
      final List<dynamic> list = res.data['message'];

      final items =
          list.map((item) {
            final model = WebsiteItemModel.fromJson(item);
            return model.toEntity();
          }).toList();

      appLogger.i(
        'Fetched ${items.length} items from remote source as images: ${items.map((e) => e.imageUrl).toList()}',
      );

      return Right(items);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, WebsiteItemModel>> fetchProductDetail(
    String itemCode,
  ) async {
    try {
      final res = await _client.client.get(
        SINGLE_WEB_ITEM_ENDPOINT,
        queryParameters: {'item_code': itemCode},
      );

      final data = res.data['message'];
      final product = WebsiteItemModel.fromJson(data);

      return Right(product);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
