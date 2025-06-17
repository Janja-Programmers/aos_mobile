import 'package:flutter/foundation.dart';

import '/core/errors/failures.dart';

import 'domain/sales_order.dart';
import 'domain/usecases.dart';

class SalesOrderProvider with ChangeNotifier {
  final GetAllSalesOrders _getAllSalesOrders;

  SalesOrderProvider({required GetAllSalesOrders getAllSalesOrders})
    : _getAllSalesOrders = getAllSalesOrders;

  List<SalesOrder> _orders = [];
  List<SalesOrder> get orders => _orders;

  bool _loading = false;
  bool get loading => _loading;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchAll() async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final result = await _getAllSalesOrders();

    result.fold((f) => _failure = f, (list) => _orders = list);

    _loading = false;
    notifyListeners();
  }

  void reset() {
    _orders = [];
    _failure = null;
    _loading = false;
    notifyListeners();
  }
}
