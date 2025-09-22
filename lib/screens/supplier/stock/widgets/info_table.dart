import 'package:flutter/material.dart';

import '/features/stock/domain/entity/stock.dart';

class StockTableCard extends StatelessWidget {
  final StockEntry entry;

  const StockTableCard({super.key, required this.entry});

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
              'Stock Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStockTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey)),
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(6), child: Text('#')),
            Padding(padding: EdgeInsets.all(6), child: Text('Item')),
            Padding(padding: EdgeInsets.all(6), child: Text('Qty')),
            Padding(padding: EdgeInsets.all(6), child: Text('Valuation')),
          ],
        ),

        // Items
        ...entry.items.asMap().entries.map((e) {
          final i = e.key + 1;
          final item = e.value;
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: Text('$i')),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.itemName),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.qty.toStringAsFixed(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.valuationRate.toStringAsFixed(2)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
