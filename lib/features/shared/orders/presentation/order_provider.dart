import 'package:flutter/material.dart';
import '../data/local_order_datasource.dart';
import '../data/order_repository_impl.dart';
import '../domain/order.dart';
import '../domain/usecases/complete_order.dart';
import '../domain/usecases/create_order.dart';
import '../domain/usecases/get_orders.dart';
import '../domain/usecases/submit_order.dart';

class OrderProvider with ChangeNotifier {
  final CreateOrder _createOrder;
  final GetOrders _getOrders;
  final SubmitOrder _submitOrder;
  final CompleteOrder _completeOrder;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrderProvider._(
    this._createOrder,
    this._getOrders,
    this._submitOrder,
    this._completeOrder,
  );

  /// Factory constructor to inject dependencies
  static Future<OrderProvider> init() async {
    final dataSource = LocalDataSource();
    final repo = OrderRepositoryImpl(dataSource);

    return OrderProvider._(
      CreateOrder(repo),
      GetOrders(repo),
      SubmitOrder(repo),
      CompleteOrder(repo),
    );
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _getOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewOrder(Order order) async {
    await _createOrder(order);
    await fetchOrders();
  }

  Future<void> submit(String orderId) async {
    await _submitOrder(orderId);
    await fetchOrders();
  }

  Future<void> complete(String orderId) async {
    await _completeOrder(orderId);
    await fetchOrders();
  }
}
