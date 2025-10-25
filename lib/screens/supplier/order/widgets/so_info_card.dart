import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/features/address/domain/address.dart';
import '/features/address/provider.dart';
import '/features/order/domain/sales_order.dart';

class SalesOrderInfoCard extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderInfoCard({super.key, required this.order});

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

    // Try to find a matching address from the provider
    Address? shippingAddress = addressProv.addresses.firstWhere(
      (a) => a.type.toLowerCase() == 'shipping',
      orElse:
          () =>
              addressProv.selectedAddress ??
              Address(
                name: '',
                title: '',
                line1: '',
                city: '',
                country: '',
                phone: '',
                type: 'Shipping',
              ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE → Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  Text(order.contactEmail ?? '-'),
                  const SizedBox(height: 4),

                  Text(
                    shippingAddress.phone.isNotEmpty
                        ? shippingAddress.phone
                        : (order.contactPhone ?? '-'),
                    style: const TextStyle(color: Colors.black87),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    shippingAddress.line1.isNotEmpty
                        ? '${shippingAddress.line1}, ${shippingAddress.city}, ${shippingAddress.country}'
                        : (order.shippingAddress.isNotEmpty
                            ? order.shippingAddress
                            : 'No address found'),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE → Order Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(order.deliveryDate)}',
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
                    color: _statusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusTextColor(order.status),
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
