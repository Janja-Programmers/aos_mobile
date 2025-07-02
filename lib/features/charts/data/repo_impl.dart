import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/repo.dart';
import '../domain/sales_chart.dart';

import 'remote.dart';

class SalesChartRepoImpl implements SalesChartRepo {
  final SalesChartRemoteDS remote;

  SalesChartRepoImpl(this.remote);

  @override
  Future<Either<Failure, SalesChart>> fetch() {
    return remote.fetch();
  }
}
