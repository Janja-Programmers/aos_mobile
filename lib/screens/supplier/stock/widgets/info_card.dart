import 'package:flutter/material.dart';

import '/shared/widgets/docstatus_chip.dart';
import '/shared/utils/doc_status.dart';

class StockEntryInfoCard extends StatelessWidget {
  final String entryId;
  final DocStatus docstatus;

  const StockEntryInfoCard({
    super.key,
    required this.entryId,
    required this.docstatus,
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
            // Row 1 → Entry ID
            Text(
              entryId,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Row 2 → Docstatus Chip
            Align(
              alignment: Alignment.centerLeft,
              child: DocstatusChip(docstatus: docstatus),
            ),
          ],
        ),
      ),
    );
  }
}
