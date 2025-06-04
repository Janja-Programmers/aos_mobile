import 'package:flutter/material.dart';

import '../../domain/order.dart';

class OrderItemWidget extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderItemWidget({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(order.customerName),
        subtitle: Text('Total: ${order.grandTotal} | ${order.status.name}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
