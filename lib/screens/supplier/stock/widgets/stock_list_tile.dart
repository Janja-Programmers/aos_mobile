import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/shared/utils/doc_status.dart';
import '/core/utils/snackbar.dart';

import '/features/stock/providers/all.dart';
import '/features/stock/providers/create.dart';

import '/shared/widgets/docstatus_chip.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: ID
            Text(
              id,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: TextDecoration.underline,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Right: Status chip
            DocstatusChip(docstatus: docstatus),
          ],
        ),
      ),
    );
  }
}
