import 'package:flutter/material.dart';
import '/features/stock/domain/entity/stock_item.dart';

class StockItemTile extends StatelessWidget {
  final StockEntryItem item;

  const StockItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ListTile(
        title: Text(
          item.itemName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Qty: ${item.qty}   Rate: ${item.valuationRate}'),
        trailing: Text(
          'Total: ${item.totalValue.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
