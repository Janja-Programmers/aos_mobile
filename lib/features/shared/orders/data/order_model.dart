import 'package:ownashop/features/shared/orders/data/order_item_model.dart';

import '../domain/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.orderType,
    required super.orderDate,
    required super.company,
    required super.items,
    required super.shippingAddress,
    required super.contactName,
    required super.contactMobile,
    required super.contactEmail,
    required super.status,
  });

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
    List<OrderItemModel> items,
  ) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      orderType: json['order_type'],
      orderDate: DateTime.parse(json['order_date']),
      company: json['company'],
      shippingAddress: json['shipping_address'],
      contactName: json['contact_name'],
      contactMobile: json['contact_mobile'],
      contactEmail: json['contact_email'],
      status: _parseStatus(json['status']),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_type': orderType,
      'order_date': orderDate.toIso8601String(),
      'company': company,
      'shipping_address': shippingAddress,
      'contact_name': contactName,
      'contact_mobile': contactMobile,
      'contact_email': contactEmail,
      'grand_total': grandTotal,
      'status': status.name,
    };
  }

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'submitted':
        return OrderStatus.submitted;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.draft;
    }
  }
}
