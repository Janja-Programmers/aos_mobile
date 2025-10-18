import 'package:flutter/material.dart';

import '/core/utils/formatters.dart';
import '/features/order/domain/sales_order.dart';

class SalesOrderItemTile extends StatelessWidget {
  final SalesOrderItem item;

  const SalesOrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with icon + item name
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Item code
            Text(
              'Code: ${item.itemCode}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 10),

            // Qty, Rate, Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile('Qty', item.qty.toStringAsFixed(0)),
                _infoTile('Rate', formatCurrency(item.rate)),
                _infoTile(
                  'Amount',
                  formatCurrency(item.amount),
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: highlight ? Colors.teal.shade700 : Colors.black,
          ),
        ),
      ],
    );
  }
}
