import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/create.dart';
import '/features/stock/providers/read.dart';

Future<void> submitStockEntry(BuildContext context, StockEntry draft) async {
  final createProvider = context.read<CreateStockEntryProvider>();
  final detailProvider = context.read<StockEntryDetailProvider>();

  // Call saveOrSubmit with submit = true
  final updated = await createProvider.saveOrSubmit(draft, submit: true);

  if (!context.mounted) return;

  if (updated == null) {
    // failure already set inside provider
    topSnackBar(
      context,
      createProvider.errorMessage ?? 'Failed to submit Stock intake',
      type: TopSnackType.error,
    );
  } else {
    topSnackBar(
      context,
      'Stock intake submitted successfully',
      type: TopSnackType.success,
    );

    await detailProvider.fetchById(updated.id);

    if (context.mounted) {
      context.pop(true);
    }
  }
}
