import 'package:flutter/material.dart';

import '/features/order/domain/sales_order.dart';

class ProductTableCard extends StatelessWidget {
  final SalesOrder order;

  const ProductTableCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildProductTable(),

            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // 🟢 Grand Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.grandTotal.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey)),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(6), child: Text('#')),
            Padding(padding: EdgeInsets.all(6), child: Text('Item')),
            Padding(padding: EdgeInsets.all(6), child: Text('Qty')),
            Padding(padding: EdgeInsets.all(6), child: Text('Rate (Sh.)')),
            Padding(padding: EdgeInsets.all(6), child: Text('Amount (Sh.)')),
          ],
        ),

        // Item rows
        ...order.items.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final item = entry.value;
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: Text('$i')),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.itemName),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text('${item.qty}'),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.rate.toStringAsFixed(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text((item.qty * item.rate).toStringAsFixed(2)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
