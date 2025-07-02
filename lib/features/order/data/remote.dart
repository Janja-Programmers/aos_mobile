import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class SalesOrderRemoteDS {
  final APIClient client;
  static const _endpoint = SALES_ORDER_ENDPOINT;

  SalesOrderRemoteDS(this.client);

  Future<Either<Failure, List<SalesOrderModel>>> getAll({String? owner}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (owner != null && owner.isNotEmpty) {
        queryParams['filters'] = '[["owner", "=", "$owner"]]';
      }

      final res = await client.client.get(
        _endpoint,
        queryParameters: queryParams,
      );

      final List data = res.data['data'];

      final futures =
          data.map((e) {
            return client.client.get('$_endpoint/${e['name']}');
          }).toList();

      final fullData = await Future.wait(futures);
      final models =
          fullData
              .map((resp) => SalesOrderModel.fromJson(resp.data['data']))
              .toList();

      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Fetch one by ID
  Future<Either<Failure, SalesOrderModel>> getById(String id) async {
    try {
      final res = await client.client.get('$_endpoint/$id');
      final model = SalesOrderModel.fromJson(res.data['data']);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Mark as delivered (PUT or custom endpoint)
  Future<Either<Failure, Unit>> markAsDelivered(String id) async {
    try {
      await client.client.put(
        '$_endpoint/$id',
        data: {'status': 'To Deliver and Bill', 'percent_delivered': 100},
      );
      return const Right(unit);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Mark as billed
  Future<Either<Failure, Unit>> markAsBilled(String id) async {
    try {
      await client.client.put(
        '$_endpoint/$id',
        data: {'status': 'To Deliver and Bill', 'percent_billed': 100},
      );
      return const Right(unit);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}

class SalesOrderPayloadRemoteDS {
  final APIClient client;

  SalesOrderPayloadRemoteDS(this.client);

  Future<Either<Failure, Unit>> placeOrder(OrderPayloadModel order) async {
    try {
      await client.client.post(PLACE_ORDER_ENDPOINT, data: order.toJson());

      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to place order: $e'));
    }
  }
}
