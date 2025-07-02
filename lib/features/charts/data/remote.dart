import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class SalesChartRemoteDS {
  final APIClient client;
  SalesChartRemoteDS(this.client);

  Future<Either<Failure, SalesChartModel>> fetch() async {
    try {
      final res = await client.client.get(
        '/api/method/frappe.desk.query_report.run',
        queryParameters: {'report_name': 'Vendor Sales Summary'},
      );

      final json = res.data['message'];
      final model = SalesChartModel.fromJson({'chart': json['chart']});
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
