import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/shared/widgets/docstatus_chip.dart';

class StockListTile extends StatelessWidget {
  final String id;
  final int docstatus;
  final String date;

  const StockListTile({
    super.key,
    required this.id,
    required this.docstatus,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push('/stock-entry/$id'),
      borderRadius: BorderRadius.circular(4),
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: ID + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DocstatusChip(docstatus: docstatus),
          ],
        ),
      ),
    );
  }
}
