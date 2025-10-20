class SalesInvoice {
  final String id;
  final String customerName;
  final String status;
  final DateTime postingDate;
  final DateTime? dueDate;
  final double grandTotal;
  final double outstandingAmount;
  final List<SalesInvoiceItem> items;
  final String? contactEmail;
  final String? contactPhone;
  final String shippingAddress;

  SalesInvoice({
    required this.id,
    required this.customerName,
    required this.status,
    required this.postingDate,
    this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.items,
    this.contactEmail,
    this.contactPhone,
    required this.shippingAddress,
  });
}

class SalesInvoiceItem {
  final String itemCode;
  final String itemName;
  final int qty;
  final double rate;
  final double amount;

  SalesInvoiceItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });
}
