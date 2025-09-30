import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

import '/features/order/domain/sales_order.dart';

class SalesInvoiceCardRow extends StatelessWidget {
  final SalesOrder invoice;

  const SalesInvoiceCardRow({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final status = invoice.status.toLowerCase();

    final Map<String, (Color bg, Color text)> statusStyles = {
      'completed': (Colors.green.shade100, Colors.green.shade800),
      'to deliver and bill': (Colors.orange.shade100, Colors.orange.shade800),
    };

    final (statusColor, statusTextColor) =
        statusStyles[status] ?? (Colors.grey.shade300, Colors.grey.shade700);

    return InkWell(
      // onTap: () => context.push('/invoice/${invoice.id}'),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Customer name + Status chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.customerName,
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
                          invoice.status,
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

                  /// Invoice ID
                  Text(invoice.id, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
