import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/order/domain/sales_order.dart';

class SalesOrderTile extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusTextColor;

    switch (order.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade800;
        break;
      case 'to deliver and bill':
        statusColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade800;
        break;
      default:
        statusColor = Colors.grey.shade300;
        statusTextColor = Colors.grey.shade700;
    }

    return InkWell(
      onTap: () => context.push('/sales-order/${order.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Delivery Date & Total
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Delivery: ${order.deliveryDate.toLocal().toString().split(' ').first}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Total: Sh ${order.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bars
              _buildProgressBar('Delivered', order.percentDelivered),
              const SizedBox(height: 6),
              _buildProgressBar('Billed', order.percentBilled),
              const SizedBox(height: 12),

              // ID (footer)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Order ID: ${order.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100.0,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              value == 100 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
