import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import 'sales_chart.dart';

abstract class SalesChartRepo {
  Future<Either<Failure, SalesChart>> fetch();
}
