import 'package:africaonlinestores/core/utils/formatters.dart';
import 'package:flutter/material.dart';

import '/features/d_note/domain/entity/delivery_note_item.dart';

class DeliveryNoteItemsTable extends StatelessWidget {
  final List<DeliveryNoteItem> items;

  const DeliveryNoteItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(30), // # column
        1: FlexColumnWidth(3), // Item name
        2: FlexColumnWidth(1), // Qty
        3: FlexColumnWidth(2), // Rate
        4: FlexColumnWidth(2), // Amount
      },
      border: TableBorder.symmetric(
        inside: const BorderSide(color: Colors.grey),
      ),
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
        ...items.asMap().entries.map((entry) {
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
                child: Text(humanizeNumber(item.qty)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(humanizeNumber(item.rate)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(humanizeNumber(item.amount)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
