import 'package:flutter/material.dart';
import '/features/stock/domain/entity/stock.dart';

class StockDetailHeader extends StatelessWidget {
  final StockEntry entry;

  const StockDetailHeader({super.key, required this.entry});

  Color getStatusColor(int docstatus) {
    switch (docstatus) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(int docstatus) {
    switch (docstatus) {
      case 0:
        return 'Draft';
      case 1:
        return 'Submitted';
      case 2:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.id,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Status: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  getStatusLabel(entry.docstatus),
                  style: TextStyle(
                    color: getStatusColor(entry.docstatus),
                    fontWeight: FontWeight.w600,
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
