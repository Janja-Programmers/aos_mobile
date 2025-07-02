import '../../cart/domain/cart.dart';

class SalesOrder {
  final String id;
  final String customerName;
  final String status;
  final DateTime deliveryDate;
  final double grandTotal;
  final double percentDelivered;
  final double percentBilled;
  final List<SalesOrderItem> items;

  SalesOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.deliveryDate,
    required this.grandTotal,
    required this.percentDelivered,
    required this.percentBilled,
    required this.items,
  });
}

class SalesOrderItem {
  final String itemCode;
  final String itemName;
  final int qty;
  final double rate;
  final double amount;

  SalesOrderItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });
}

class OrderPayload {
  final String customer;
  final String deliveryDate;
  final int docstatus;
  final List<CartItem> items;
  final String shippingAddress;
  final String customerAddress;
  final String addressType;

  OrderPayload({
    required this.customer,
    required this.deliveryDate,
    required this.items,
    required this.shippingAddress,
    required this.customerAddress,
    required this.addressType,
    this.docstatus = 1,
  });

  String get shippingAddressName => shippingAddress;

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "delivery_date": deliveryDate,
    "docstatus": docstatus,
    "items": items.map((item) => item.toJson()).toList(),
    "shipping_address": shippingAddress,
    "customer_address": customerAddress,
    "address_type": addressType,
  };
}
