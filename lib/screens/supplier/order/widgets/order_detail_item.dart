import 'package:flutter/material.dart';

import '/features/order/domain/sales_order.dart';

class SalesOrderItemTile extends StatelessWidget {
  final SalesOrderItem item;

  const SalesOrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.itemName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Code: ${item.itemCode}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile('Qty', item.qty.toString()),
                _infoTile('Rate', 'Sh ${item.rate.toStringAsFixed(2)}'),
                _infoTile('Amount', 'Sh ${item.amount.toStringAsFixed(2)}'),
              ],
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
