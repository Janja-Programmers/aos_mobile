import 'package:flutter/material.dart';

import '/features/d_note/domain/entity/delivery_note_item.dart';

class DeliveryNoteItemsTable extends StatelessWidget {
  final List<DeliveryNoteItem> items;

  const DeliveryNoteItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.grey.shade300),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            Padding(padding: EdgeInsets.all(6), child: Text('Item')),
            Padding(padding: EdgeInsets.all(6), child: Text('Qty')),
            Padding(padding: EdgeInsets.all(6), child: Text('Rate')),
            Padding(padding: EdgeInsets.all(6), child: Text('Amount')),
          ],
        ),
        ...items.map((item) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  '${item.itemName} (${item.itemCode})',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.qty.toStringAsFixed(0)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.rate.toStringAsFixed(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item.amount.toStringAsFixed(2)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
