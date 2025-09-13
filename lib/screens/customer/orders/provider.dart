import 'package:flutter/material.dart';
import '/features/order/data/remote.dart';

class CustomerOrderProvider extends ChangeNotifier {
  final SalesOrderRemoteDS remoteDS;

  CustomerOrderProvider(this.remoteDS);

  List<Map<String, dynamic>> _orders = [];
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _loading = true;
    notifyListeners();

    final result = await remoteDS.getCustomerOrders();

    result.fold(
      (failure) {
        _error = failure.message;
        _orders = [];
      },
      (models) {
        _error = null;
        _orders = models.map(toCustomerOrderMap).toList();
      },
    );

    _loading = false;
    notifyListeners();
  }
}
