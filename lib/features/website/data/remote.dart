import 'dart:convert';

import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import '../domain/webitem.dart';

import 'model.dart';

class WebsiteRemoteDataSource {
  final APIClient _client;
  static const webItemApi = ApiRoutes.webItem;
  static const singleWebItemApi = ApiRoutes.singleWebItem;

  WebsiteRemoteDataSource(this._client);

  Future<Either<Failure, List<WebsiteItem>>> fetchItems({
    required int start,
    String? search,
  }) async {
    try {
      final res = await _client.client.get(
        webItemApi,
        queryParameters: {
          'query_args': jsonEncode({
            'start': start,
            if (search != null && search.isNotEmpty) 'search': search,
          }),
        },
      );

      final List<dynamic> list = res.data['message']['items'] ?? [];

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
        singleWebItemApi,
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
