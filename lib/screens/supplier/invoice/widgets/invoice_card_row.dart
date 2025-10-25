import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/features/invoice/domain/sales_invoice.dart';

class SalesInvoiceCardRow extends StatelessWidget {
  final SalesInvoice invoice;

  const SalesInvoiceCardRow({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final status = invoice.status.toLowerCase().trim();

    // Define beautiful chips for each status
    final Map<String, (Color bg, Color text)> statusStyles = {
      'paid': (Colors.green.shade100, Colors.green.shade800),
      'unpaid': (Colors.orange.shade100, Colors.orange.shade800),
      'draft': (Colors.blue.shade100, Colors.blue.shade800),
      'partially paid': (Colors.teal.shade100, Colors.teal.shade800),
      'submitted': (Colors.indigo.shade100, Colors.indigo.shade800),
    };

    final (bgColor, textColor) =
        statusStyles[status] ?? (Colors.grey.shade200, Colors.grey.shade700);

    return InkWell(
      onTap: () => context.push('/invoice/${invoice.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                          invoice.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        label: invoice.status,
                        bgColor: bgColor,
                        textColor: textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Invoice ID
                  Text(
                    invoice.customerName,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: textColor, size: 14),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
