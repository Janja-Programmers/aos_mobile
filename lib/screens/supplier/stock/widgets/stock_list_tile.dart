import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/shared/utils/doc_status.dart';
import '/core/utils/snackbar.dart';

import '/features/stock/providers/all.dart';
import '/features/stock/providers/create.dart';

import '/shared/widgets/docstatus_chip.dart';

import '../utils/delete_stock_entry.dart';

class StockListTile extends StatelessWidget {
  final String id;
  final DocStatus docstatus;

  const StockListTile({super.key, required this.id, required this.docstatus});

  Future<void> _navigateToEntryDetail(BuildContext context) async {
    if (docstatus == 0) {
      final provider = context.read<CreateStockEntryProvider>();
      final entry = await provider.getById(id);

      if (context.mounted && entry != null) {
        final result = await context.push('/stock/edit', extra: entry);
        if (result == true && context.mounted) {
          context.read<StockEntryProvider>().fetchAll();
        }
      } else {
        topSnackBar(context, 'Could not load draft.', type: TopSnackType.error);
      }
    } else {
      final result = await context.push('/stock-entry/$id');
      if (result == true && context.mounted) {
        context.read<StockEntryProvider>().fetchAll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _navigateToEntryDetail(context),
      borderRadius: BorderRadius.circular(6),
      splashColor: theme.colorScheme.primary.withOpacity(0.08),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Left: ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // reduced from 16 → 14
                    overflow: TextOverflow.ellipsis,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 6),
                DocstatusChip(docstatus: docstatus),
              ],
            ),

            // Right: Actions
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (docstatus == 0) // Draft → edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Draft',
                        onPressed: () => _navigateToEntryDetail(context),
                      ),
                    if (docstatus == 1) // Submitted → view
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.green,
                        ),
                        tooltip: 'View',
                        onPressed: () => _navigateToEntryDetail(context),
                      ),
                    if (docstatus == 2) // Cancelled → delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final success = await deleteStockEntry(context, id);
                          if (success == true) {
                            context.read<StockEntryProvider>().fetchAll();
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
