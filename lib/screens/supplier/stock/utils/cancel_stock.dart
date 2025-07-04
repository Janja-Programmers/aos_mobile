import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/create.dart';
import '/features/stock/providers/read.dart';

Future<void> cancelStockEntry(
  BuildContext context,
  StockEntry submitted,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Cancel Entry?'),
          content: const Text(
            'This action cannot be undone. Are you sure you want to cancel this stock entry?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
  );

  if (confirmed != true) return;

  final provider = context.read<CreateStockEntryProvider>();
  final detailProvider = context.read<StockEntryDetailProvider>();

  final cancelled = submitted.copyWith(docstatus: 2);
  await provider.update(cancelled);

  if (!context.mounted) return;

  if (provider.hasError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(provider.failure!.message)));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock Entry cancelled successfully')),
    );

    // Refresh the detail view
    await detailProvider.fetchById(submitted.id);
  }
}
