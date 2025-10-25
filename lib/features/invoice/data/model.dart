import '/features/address/data/model.dart';

import '../domain/sales_invoice.dart';

class SalesInvoiceModel {
  final String id;
  final String customerName;
  final String customer;
  final String status;
  final DateTime postingDate;
  final DateTime? dueDate;
  final double grandTotal;
  final double outstandingAmount;
  final List<SalesInvoiceItemModel> items;

  final String? contactEmail;
  final String? customerPhone;
  final String shippingAddress;

  SalesInvoiceModel({
    required this.id,
    required this.customerName,
    required this.customer,
    required this.status,
    required this.postingDate,
    this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.items,
    required this.shippingAddress,
    this.contactEmail,
    this.customerPhone,
  });

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];

    // graceful handling for address display
    final String addressHtml =
        json['shipping_address_display'] ?? json['shipping_address'] ?? '';
    final addressModel = _parseAddressHtml(addressHtml);

    return SalesInvoiceModel(
      id: json["name"] ?? '',
      customerName: json["customer_name"] ?? '',
      customer: json["customer"] ?? '',
      status: json["status"] ?? '',
      postingDate:
          DateTime.tryParse(json["posting_date"] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json["due_date"] ?? ''),
      grandTotal: (json["grand_total"] as num?)?.toDouble() ?? 0.0,
      outstandingAmount:
          (json["outstanding_amount"] as num?)?.toDouble() ?? 0.0,
      items:
          itemsJson
              .map((item) => SalesInvoiceItemModel.fromJson(item))
              .toList(),
      contactEmail: json['contact_email'],
      customerPhone: addressModel.phone,
      shippingAddress:
          addressModel.line1.isNotEmpty
              ? '${addressModel.line1}, ${addressModel.city}, ${addressModel.country}'
              : addressHtml,
    );
  }

  static AddressModel _parseAddressHtml(String? html) {
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

    final lines =
        html
            .split('<br>')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    String phone = '';
    for (final line in lines) {
      if (line.toLowerCase().startsWith('phone')) {
        phone = line.split(':').last.trim();
      }
    }

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

  SalesInvoice toEntity() => SalesInvoice(
    id: id,
    customerName: customerName,
    customer: customer,
    status: status,
    postingDate: postingDate,
    dueDate: dueDate,
    grandTotal: grandTotal,
    outstandingAmount: outstandingAmount,
    items: items.map((e) => e.toEntity()).toList(),
    contactEmail: contactEmail,
    contactPhone: customerPhone,
    shippingAddress: shippingAddress,
  );
}

class SalesInvoiceItemModel {
  final String itemCode;
  final String itemName;
  final int qty;
  final double rate;
  final double amount;

  SalesInvoiceItemModel({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory SalesInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItemModel(
      itemCode: json["item_code"] ?? '',
      itemName: json["item_name"] ?? '',
      qty: (json["qty"] as num?)?.toInt() ?? 0,
      rate: (json["rate"] as num?)?.toDouble() ?? 0.0,
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
    );
  }

  SalesInvoiceItem toEntity() => SalesInvoiceItem(
    itemCode: itemCode,
    itemName: itemName,
    qty: qty,
    rate: rate,
    amount: amount,
  );
}
