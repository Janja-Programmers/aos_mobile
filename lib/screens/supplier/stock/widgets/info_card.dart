import 'package:flutter/material.dart';

import '/shared/widgets/docstatus_chip.dart';
import '/shared/utils/doc_status.dart';

class StockEntryInfoCard extends StatelessWidget {
  final String entryId;
  final DocStatus docstatus;
  final String? date;

  const StockEntryInfoCard({
    super.key,
    required this.entryId,
    required this.docstatus,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entryId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                DocstatusChip(docstatus: docstatus),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2 → Date (optional)
            if (date != null)
              Text(
                'Date: ${date!}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
