import '/features/address/data/model.dart';

import '../domain/sales_order.dart';

class SalesOrderModel {
  final String id;
  final String customerName;
  final String status;
  final DateTime deliveryDate;
  final double grandTotal;
  final double percentDelivered;
  final double percentBilled;
  final List<SalesOrderItemModel> items;

  // 👇 New fields for customer info
  final String? contactEmail;
  final String? customerPhone;
  final String shippingAddress;

  SalesOrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.deliveryDate,
    required this.grandTotal,
    required this.percentDelivered,
    required this.percentBilled,
    required this.items,
    required this.shippingAddress,
    this.contactEmail,
    this.customerPhone,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    AddressModel parseAddressHtml(String? html) {
      if (html == null || html.trim().isEmpty) {
        return AddressModel(
          name: '',
          title: '',
          line1: '',
          city: '',
          country: '',
          phone: '',
          type: 'Shipping',
        );
      }

      // Split HTML by <br> and clean each line
      final lines =
          html
              .split('<br>')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      // Find phone line if present
      String phone = '';
      for (final line in lines) {
        if (line.toLowerCase().startsWith('phone')) {
          phone = line.split(':').last.trim();
        }
      }

      // Heuristic: assume first non-phone line is address/city
      String line1 = lines.isNotEmpty ? lines.first : '';
      String city = lines.length > 1 ? lines[1] : '';
      String country = lines.length > 2 ? lines[2] : '';

      return AddressModel(
        name: '',
        title: '',
        line1: line1,
        city: city,
        country: country,
        phone: phone,
        type: 'Shipping',
      );
    }

    final List<dynamic> itemsJson = json['items'] ?? [];
    final addressHtml =
        json['shipping_address_display'] ?? json['shipping_address'];
    final addressModel = parseAddressHtml(addressHtml);

    return SalesOrderModel(
      id: json["name"],
      customerName: json["customer_name"],
      status: json["status"],
      deliveryDate: DateTime.parse(json["transaction_date"]),
      grandTotal: (json["grand_total"] as num).toDouble(),
      percentDelivered: (json["per_delivered"] as num).toDouble(),
      percentBilled: (json["per_billed"] as num).toDouble(),
      items:
          itemsJson.map((item) => SalesOrderItemModel.fromJson(item)).toList(),
      contactEmail: json['contact_email'],
      customerPhone: addressModel.phone,
      shippingAddress:
          addressModel.line1.isNotEmpty
              ? '${addressModel.line1}, ${addressModel.city}, ${addressModel.country}'
              : addressHtml ?? '',
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
    items: items.map((e) => e.toEntity()).toList(),
    shippingAddress: shippingAddress,
    contactEmail: contactEmail,
    contactPhone: customerPhone,
  );
}

class SalesOrderItemModel {
  final String itemCode;
  final String itemName;
  final int qty;
  final double rate;
  final double amount;

  SalesOrderItemModel({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory SalesOrderItemModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderItemModel(
      itemCode: json["item_code"],
      itemName: json["item_name"],
      qty: (json["qty"] as num).toInt(),
      rate: (json["rate"] as num).toDouble(),
      amount: (json["amount"] as num).toDouble(),
    );
  }

  SalesOrderItem toEntity() => SalesOrderItem(
    itemCode: itemCode,
    itemName: itemName,
    qty: qty,
    rate: rate,
    amount: amount,
  );
}

class OrderPayloadModel {
  final String customer;
  final String deliveryDate;
  final List<Map<String, dynamic>> items;
  final String shippingAddress;
  final String customerAddress;
  final String addressType;
  final int docstatus;

  OrderPayloadModel({
    required this.customer,
    required this.deliveryDate,
    required this.items,
    required this.shippingAddress,
    required this.customerAddress,
    required this.addressType,
    this.docstatus = 1,
  });

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "delivery_date": deliveryDate,
    "docstatus": docstatus,
    "items": items,
    "shipping_address": shippingAddress,
    "customer_address": customerAddress,
    "address_type": addressType,
  };

  factory OrderPayloadModel.fromEntity(OrderPayload payload) {
    final address = payload.shippingAddressName;
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
      shippingAddress: '$address-Shipping',
      customerAddress: '$address-Shipping',
      addressType: 'Shipping',
    );
  }

  static List<SalesOrderModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => SalesOrderModel.fromJson(e)).toList();
  }
}
