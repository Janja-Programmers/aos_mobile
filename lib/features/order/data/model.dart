import '../domain/sales_order.dart';

class SalesOrderModel extends SalesOrder {
  SalesOrderModel({
    required super.id,
    required super.customerName,
    required super.status,
    required super.deliveryDate,
    required super.grandTotal,
    required super.percentDelivered,
    required super.percentBilled,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json["name"],
      customerName: json["customer_name"],
      status: json["status"],
      deliveryDate: DateTime.parse(json["transaction_date"]),
      grandTotal: (json["grand_total"] as num).toDouble(),
      percentDelivered: (json["per_delivered"] as num).toDouble(),
      percentBilled: (json["per_billed"] as num).toDouble(),
    );
  }
}
