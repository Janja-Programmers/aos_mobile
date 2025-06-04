enum OrderStatus { draft, submitted, completed }

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String orderType; // default "Sales"
  final DateTime orderDate; // default today
  final String company; // default "Ownashop"
  final List<OrderItem> items;
  final double grandTotal;
  final String shippingAddress;
  final String contactName;
  final String contactMobile;
  final String contactEmail;
  final OrderStatus status;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.shippingAddress,
    required this.contactName,
    required this.contactMobile,
    required this.contactEmail,
    this.orderType = "Sales",
    DateTime? orderDate,
    this.company = "Ownashop",
    this.status = OrderStatus.draft,
  }) : orderDate = orderDate ?? DateTime.now(),
       grandTotal = items.fold(0, (sum, item) => sum + item.amount);
}

class OrderItem {
  final int sno;
  final String itemId;
  final String name;
  final DateTime deliveryDate;
  final int quantity;
  final double rate;
  double get amount => quantity * rate;

  OrderItem({
    required this.sno,
    required this.itemId,
    required this.name,
    required this.deliveryDate,
    required this.quantity,
    required this.rate,
  });
}
