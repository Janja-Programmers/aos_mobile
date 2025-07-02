import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/create.dart';
import '/features/stock/providers/read.dart';

Future<void> submitStockEntry(BuildContext context, StockEntry draft) async {
  final provider = context.read<CreateStockEntryProvider>();
  final detailProvider = context.read<StockEntryDetailProvider>();

  final updated = draft.copyWith(docstatus: 1);
  await provider.update(updated);

  if (!context.mounted) return;

  if (provider.hasError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(provider.failure!.message)));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock Entry submitted successfully')),
    );

    // Refresh detail
    await detailProvider.fetchById(draft.id);
  }
}
