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

  Future<Either<Failure, List<SalesOrderModel>>> getAll() async {
    try {
      final res = await client.client.get(_endpoint);
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
}

class SalesOrderPayloadRemoteDS {
  final APIClient client;

  SalesOrderPayloadRemoteDS(this.client);

  Future<Either<Failure, Unit>> placeOrder(OrderPayloadModel order) async {
    try {
      print("🧪 Entered placeOrder in REMOTE.DART");

      await client.client.post(PLACE_ORDER_ENDPOINT, data: order.toJson());

      print("🟢 POST succeeded in REMOTE.DART");
      return const Right(unit);
    } catch (e) {
      print("❌ Exception caught in REMOTE.DART: $e");
      return Left(handleException('Failed to place order: $e'));
    }
  }
}
