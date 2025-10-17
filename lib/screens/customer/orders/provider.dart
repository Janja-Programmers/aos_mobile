import 'package:flutter/material.dart';

import '/features/order/data/remote.dart';
import '/features/order/domain/sales_order.dart';

class CustomerOrderProvider extends ChangeNotifier {
  final SalesOrderRemoteDS remoteDS;

  CustomerOrderProvider(this.remoteDS);

  List<SalesOrder> _orders = [];
  bool _loading = false;
  String? _error;

  List<SalesOrder> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await remoteDS.getCustomerOrders();

    result.fold(
      (failure) {
        _error = failure.message;
        _orders = [];
      },
      (models) {
        _orders = models.map((m) => m.toEntity()).toList();
      },
    );

    _loading = false;
    notifyListeners();
  }

  Future<SalesOrder?> fetchOrderById(String id) async {
    final result = await remoteDS.getById(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return null;
      },
      (order) {
        _error = null;
        return order;
      },
    );
  }
}
