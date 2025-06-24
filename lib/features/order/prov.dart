import 'package:flutter/foundation.dart';
import '/core/errors/failures.dart';

import 'domain/sales_order.dart';
import 'domain/usecases.dart';

class SalesOrderProvider with ChangeNotifier {
  final GetAllSalesOrders _getAllSalesOrders;
  final PlaceOrderUseCase _placeOrderUseCase;

  SalesOrderProvider({
    required GetAllSalesOrders getAllSalesOrders,
    required PlaceOrderUseCase placeOrderUseCase,
  }) : _getAllSalesOrders = getAllSalesOrders,
       _placeOrderUseCase = placeOrderUseCase;

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

  Future<bool> placeOrder(OrderPayload payload) async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final result = await _placeOrderUseCase(payload);
    final success = result.isRight();

    result.fold((f) => _failure = f, (_) => null);

    _loading = false;
    notifyListeners();

    if (success) {
      await fetchAll();
    }

    return success;
  }

  void reset() {
    _orders = [];
    _failure = null;
    _loading = false;
    notifyListeners();
  }
}
