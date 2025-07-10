import 'package:flutter/foundation.dart';
import '/core/errors/failures.dart';

import 'domain/sales_order.dart';
import 'domain/usecases.dart';

import 'package:dartz/dartz.dart';

class SalesOrderProvider with ChangeNotifier {
  final GetAllSalesOrders getAllSalesOrders;
  final GetSalesOrderById getById;
  final DeliverSalesOrder deliver;
  final BillSalesOrder bill;
  final PlaceOrderUseCase placeOrder;

  SalesOrderProvider({
    required this.getAllSalesOrders,
    required this.getById,
    required this.deliver,
    required this.bill,
    required this.placeOrder,
  });

  List<SalesOrder> _orders = [];
  List<SalesOrder> get orders => _orders;

  SalesOrder? _selectedOrder;
  SalesOrder? get selectedOrder => _selectedOrder;

  bool _listLoading = false;
  bool _detailLoading = false;

  bool get listLoading => _listLoading;
  bool get detailLoading => _detailLoading;
  bool get hasError => _failure != null;

  Failure? _failure;
  Failure? get failure => _failure;

  /// Fetch all sales orders
  Future<void> fetchAll() async {
    _setListLoading(true);

    final result = await getAllSalesOrders();
    result.fold(
      (f) {
        _failure = f;
        _orders = [];
      },
      (list) {
        _failure = null;
        _orders = list;
      },
    );

    _setListLoading(false);
  }

  /// Fetch single order by ID
  Future<void> fetchById(String id) async {
    _setDetailLoading(true);
    _failure = null;

    final result = await getById(id);
    result.fold((f) => _failure = f, (order) => _selectedOrder = order);

    _setDetailLoading(false);
  }

  /// Mark sales order as delivered
  // ignore: non_constant_identifier_names
  Future<Either<Failure, Unit>> deliverOrder(String id) async {
    _setDetailLoading(true);

    final result = await deliver(id);
    if (result.isRight()) {
      await fetchById(id);
    }

    _setDetailLoading(false);
    return result;
  }

  Future<Either<Failure, Unit>> billOrder(String id) async {
    _setDetailLoading(true);

    final result = await bill(id);
    if (result.isRight()) {
      await fetchById(id);
    }

    _setDetailLoading(false);
    return result;
  }

  void reset() {
    _orders = [];
    _selectedOrder = null;
    _failure = null;
    _listLoading = false;
    _detailLoading = false;
    notifyListeners();
  }

  void _setListLoading(bool value) {
    _listLoading = value;
    notifyListeners();
  }

  void _setDetailLoading(bool value) {
    _detailLoading = value;
    notifyListeners();
  }

  Future<Either<Failure, Unit>> placeOrderRequest(OrderPayload payload) async {
    _setListLoading(true);
    _failure = null;

    final result = await placeOrder(payload);

    result.fold((f) => _failure = f, (_) async {
      await fetchAll();
    });

    _setListLoading(false);
    return result;
  }

  bool get hasOrders => _orders.isNotEmpty;
}
