import 'package:flutter/material.dart';

import '/core/errors/failures.dart';

import '../domain/sales_chart.dart';
import '../domain/usecase.dart';

class SalesChartProvider with ChangeNotifier {
  final GetSalesChart getChart;

  SalesChartProvider({required this.getChart});

  SalesChart? _chart;
  SalesChart? get chart => _chart;

  bool _loading = false;
  bool get loading => _loading;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchChart() async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final result = await getChart();
    result.fold((f) => _failure = f, (c) => _chart = c);

    _loading = false;
    notifyListeners();
  }
}
