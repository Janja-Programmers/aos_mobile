import 'package:flutter/material.dart';
import '../../domain/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order: ${order.customerName}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _infoRow('Order ID', order.id),
          _infoRow('Date', order.orderDate.toString().split(' ').first),
          _infoRow('Status', order.status.name),
          _infoRow('Total', order.grandTotal.toStringAsFixed(2)),
          const Divider(),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ...order.items.map(_buildItemTile),
          const Divider(),
          _infoRow('Ship To', order.shippingAddress),
          _infoRow('Contact', '${order.contactName} (${order.contactMobile})'),
          _infoRow('Email', order.contactEmail),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Widget _buildItemTile(OrderItem item) => ListTile(
    title: Text(item.name),
    subtitle: Text('Qty: ${item.quantity} x ${item.rate}'),
    trailing: Text(item.amount.toStringAsFixed(2)),
  );
}
