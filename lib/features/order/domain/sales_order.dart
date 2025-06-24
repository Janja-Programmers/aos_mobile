import '../../cart/domain/cart.dart';

class SalesOrder {
  final String id;
  final String customerName;
  final String status;
  final DateTime deliveryDate;
  final double grandTotal;
  final double percentDelivered;
  final double percentBilled;

  SalesOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.deliveryDate,
    required this.grandTotal,
    required this.percentDelivered,
    required this.percentBilled,
  });
}

class OrderPayload {
  final String customer;
  final String deliveryDate;
  final List<CartItem> items;

  OrderPayload({
    required this.customer,
    required this.deliveryDate,
    required this.items,
  });
}
