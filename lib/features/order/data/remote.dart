import 'package:dartz/dartz.dart';
import 'package:ownashop/core/constants/const.dart';

import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class SalesOrderRemoteDS {
  final APIClient client;

  SalesOrderRemoteDS(this.client);

  Future<Either<Failure, List<SalesOrderModel>>> getAll() async {
    try {
      final res = await client.client.get(SALES_ORDER_ENDPOINT);
      final List data = res.data['data'];

      final futures =
          data.map((e) {
            return client.client.get('$SALES_ORDER_ENDPOINT/${e['name']}');
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
