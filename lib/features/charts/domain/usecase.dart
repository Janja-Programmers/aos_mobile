import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'repo.dart';
import 'sales_chart.dart';

class GetSalesChart {
  final SalesChartRepo repo;

  GetSalesChart(this.repo);

  Future<Either<Failure, SalesChart>> call() async {
    return await repo.fetch();
  }
}
