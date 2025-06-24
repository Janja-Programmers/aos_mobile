import '../domain/sales_order.dart';

class SalesOrderModel {
  final String id;
  final String customerName;
  final String status;
  final DateTime deliveryDate;
  final double grandTotal;
  final double percentDelivered;
  final double percentBilled;

  SalesOrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.deliveryDate,
    required this.grandTotal,
    required this.percentDelivered,
    required this.percentBilled,
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

  SalesOrder toEntity() => SalesOrder(
    id: id,
    customerName: customerName,
    status: status,
    deliveryDate: deliveryDate,
    grandTotal: grandTotal,
    percentDelivered: percentDelivered,
    percentBilled: percentBilled,
  );
}

class OrderPayloadModel {
  final String customer;
  final String deliveryDate;
  final List<Map<String, dynamic>> items;
  final int docstatus;

  OrderPayloadModel({
    required this.customer,
    required this.deliveryDate,
    required this.items,
    this.docstatus = 1,
  });

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "delivery_date": deliveryDate,
    "docstatus": docstatus,
    "items": items,
  };

  factory OrderPayloadModel.fromEntity(OrderPayload payload) {
    return OrderPayloadModel(
      customer: payload.customer,
      deliveryDate: payload.deliveryDate,
      items:
          payload.items
              .map(
                (e) => {
                  "item_code": e.code,
                  "qty": e.quantity,
                  "rate": e.price,
                },
              )
              .toList(),
    );
  }

  static List<SalesOrderModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => SalesOrderModel.fromJson(e)).toList();
  }
}
