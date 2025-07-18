import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/d_note/domain/entity/delivery_note.dart';

class DeliveryNoteCardRow extends StatelessWidget {
  final DeliveryNote note;

  const DeliveryNoteCardRow({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey.shade300;
    Color statusTextColor = Colors.grey.shade700;

    switch (note.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade800;
        break;
      case 'submitted':
        statusColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade800;
        break;
      case 'draft':
        statusColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade800;
        break;
    }

    return InkWell(
      onTap: () {
        context.push('/delivery-note/${note.id}'); // Adjust route
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: Colors.blueGrey),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.customerName,
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
                          note.status,
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

                  // Installed and Total
                  Text(
                    '% Installed: ${note.percentInstalled.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Total: Sh ${note.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Delivery Note ID: ${note.id}',
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
