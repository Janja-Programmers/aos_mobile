import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '../domain/item.dart';
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(TimeoutFailure());
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(NetworkFailure());
      } else {
        return Left(ServerFailure(e.message ?? 'Server error'));
      }
    } on FormatException {
      return Left(ParsingFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}
