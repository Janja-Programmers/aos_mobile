import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/order/domain/sales_order.dart';

class SalesOrderCardRow extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderCardRow({super.key, required this.order});

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Colors.blueGrey),
            const SizedBox(width: 12),

            // Expanded Column for content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 6),

                  // Delivery date
                  Text(
                    'Delivery: ${order.deliveryDate.toLocal().toString().split(' ').first}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),

                  // Total
                  Text(
                    'Total: Sh ${order.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Order ID: ${order.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
