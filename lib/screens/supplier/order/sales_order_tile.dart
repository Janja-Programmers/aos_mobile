import 'package:flutter/material.dart';

import '/features/order/domain/sales_order.dart';

class SalesOrderTile extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green.shade100;
        break;
      case 'to deliver and bill':
        statusColor = Colors.orange.shade100;
        break;
      default:
        statusColor = Colors.grey.shade300;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Delivery: ${order.deliveryDate}'),
            Text('Total: Sh ${order.grandTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            // Progress Bars
            _buildProgressBar('Delivered', order.percentDelivered),
            const SizedBox(height: 4),
            _buildProgressBar('Billed', order.percentBilled),
            const SizedBox(height: 8),
            Text(
              'ID: ${order.id}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text('$label:')),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100.0,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              value == 100 ? Colors.green : Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${value.toStringAsFixed(0)}%'),
      ],
    );
  }
}
