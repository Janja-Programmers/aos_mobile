import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'repo.dart';
import 'sales_order.dart';

class GetAllSalesOrders {
  final SalesOrderRepo repo;

  GetAllSalesOrders(this.repo);

  Future<Either<Failure, List<SalesOrder>>> call() => repo.getAll();
}

class PlaceOrderUseCase {
  final SalesOrderRepo repo;

  PlaceOrderUseCase(this.repo);

  Future<Either<Failure, Unit>> call(OrderPayload payload) {
    return repo.placeOrder(payload);
  }
}

// NEW: Fetch a single sales order by ID
class GetSalesOrderById {
  final SalesOrderRepo repo;

  GetSalesOrderById(this.repo);

  Future<Either<Failure, SalesOrder>> call(String id) {
    return repo.getById(id);
  }
}

// NEW: Deliver an order
class DeliverSalesOrder {
  final SalesOrderRepo repo;

  DeliverSalesOrder(this.repo);

  Future<Either<Failure, Unit>> call(String id) {
    return repo.markAsDelivered(id);
  }
}

// NEW: Bill an order
class BillSalesOrder {
  final SalesOrderRepo repo;

  BillSalesOrder(this.repo);

  Future<Either<Failure, Unit>> call(String id) {
    return repo.markAsBilled(id);
  }
}
