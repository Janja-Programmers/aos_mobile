import 'package:flutter/material.dart';
import '/features/stock/domain/entity/stock.dart';

class StockDetailHeader extends StatelessWidget {
  final StockEntry entry;

  const StockDetailHeader({super.key, required this.entry});

  Color getStatusColor(int docstatus) {
    switch (docstatus) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return const Color.fromARGB(255, 215, 116, 109);
      default:
        return Colors.orange;
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
    final theme = Theme.of(context);

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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: '),
                Chip(
                  label: Text(
                    getStatusLabel(entry.docstatus),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: getStatusColor(entry.docstatus),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
