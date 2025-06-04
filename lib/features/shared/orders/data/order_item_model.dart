import '../domain/order.dart';

class OrderItemModel extends OrderItem {
  OrderItemModel({
    required super.sno,
    required super.itemId,
    required super.name,
    required super.deliveryDate,
    required super.quantity,
    required super.rate,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      sno: json['sno'],
      itemId: json['item_id'],
      name: json['item_name'],
      deliveryDate: DateTime.parse(json['delivery_date']),
      quantity: json['quantity'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson(String orderId) {
    return {
      'order_id': orderId,
      'sno': sno,
      'item_id': itemId,
      'item_name': name,
      'delivery_date': deliveryDate.toIso8601String(),
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }
}
