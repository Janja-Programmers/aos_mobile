import 'package:flutter/material.dart';
import '../../domain/entities/stock_entry.dart';

class StockEntryCard extends StatelessWidget {
  final StockEntry stockEntry;
  final VoidCallback onTap;

  const StockEntryCard({
    super.key,
    required this.stockEntry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(stockEntry.stockEntryType),
        subtitle: Text('Date: ${stockEntry.date.toIso8601String()}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
