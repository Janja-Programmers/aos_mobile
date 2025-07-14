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
      appLogger.i("✅ API Response of fetch ITEMS: ${res.data}");
      final List<dynamic> list = res.data['message']['items'];

      final items =
          list.map((item) {
            final model = WebsiteItemModel.fromJson(item);
            return model.toEntity();
          }).toList();

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
      final product = WebsiteItemModel.fromDetailJson(data);

      return Right(product);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
