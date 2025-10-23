import 'package:flutter/material.dart';

import '/features/invoice/domain/sales_invoice.dart';

class SalesInvoiceInfoCard extends StatelessWidget {
  final SalesInvoice invoice;

  const SalesInvoiceInfoCard({super.key, required this.invoice});

  // Background color depending on invoice status
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade100;
      case 'unpaid':
        return Colors.orange.shade100;
      case 'overdue':
        return Colors.red.shade100;
      case 'cancelled':
        return Colors.grey.shade200;
      default:
        return Colors.blue.shade100;
    }
  }

  // Text color depending on invoice status
  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade800;
      case 'unpaid':
        return Colors.orange.shade800;
      case 'overdue':
        return Colors.red.shade800;
      case 'cancelled':
        return Colors.grey.shade800;
      default:
        return Colors.blue.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE → Customer + Invoice info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  if (invoice.contactEmail != null &&
                      invoice.contactEmail!.isNotEmpty)
                    Text(
                      invoice.contactEmail!,
                      style: const TextStyle(color: Colors.black87),
                    ),

                  if (invoice.contactPhone != null &&
                      invoice.contactPhone!.isNotEmpty)
                    Text(
                      invoice.contactPhone!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                ],
              ),
            ),

            // RIGHT SIDE → Status + Invoice ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  invoice.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(invoice.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusTextColor(invoice.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
