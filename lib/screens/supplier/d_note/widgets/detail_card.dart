import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/address/provider.dart';
import '/features/address/domain/address.dart';

class DetailCard extends StatelessWidget {
  final String customerName;
  final String orderId;
  final String status;

  const DetailCard({
    super.key,
    required this.customerName,
    required this.orderId,
    required this.status,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'submitted':
        return Colors.blue.shade100;
      case 'draft':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade800;
      case 'submitted':
        return Colors.blue.shade800;
      case 'draft':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProv = context.watch<AddressProvider>();
    Address? address =
        addressProv.selectedAddress ?? addressProv.addresses.firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Customer & Address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (address != null) ...[
                    Text(address.line1),
                    const SizedBox(height: 4),

                    Text('${address.city}, ${address.country}'),
                    const SizedBox(height: 4),

                    Text(
                      '📞 ${address.phone}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ] else
                    const Text('---', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // Right: Order ID + Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  orderId,
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
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusTextColor(status),
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
