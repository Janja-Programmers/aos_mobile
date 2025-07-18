import 'package:flutter/material.dart';

import '/features/order/domain/sales_order.dart';

class OrderSummaryCard extends StatelessWidget {
  final SalesOrder order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(order.status)),
                const SizedBox(width: 10),
                Text(
                  'ID: ${order.id}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(
                  'Grand Total',
                  'Sh ${order.grandTotal.toStringAsFixed(2)}',
                ),
                _infoTile('% Delivered', '${order.percentDelivered}%'),
                _infoTile('% Billed', '${order.percentBilled}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Delivery Date: ${order.deliveryDate.toLocal().toString().split(' ').first}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
