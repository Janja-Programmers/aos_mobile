import 'package:flutter/material.dart';
import '/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/create.dart';
import '/features/stock/providers/read.dart';

Future<void> submitStockEntry(BuildContext context, StockEntry draft) async {
  final createProvider = context.read<CreateStockEntryProvider>();
  final detailProvider = context.read<StockEntryDetailProvider>();

  final updated = draft.copyWith(docstatus: 1);
  await createProvider.updateDraft(updated);

  if (!context.mounted) return;

  if (createProvider.hasError) {
    topSnackBar(
      context,
      createProvider.failure!.message,
      type: TopSnackType.error,
    );
  } else {
    topSnackBar(
      context,
      'Stock Entry submitted successfully',
      type: TopSnackType.success,
    );

    await detailProvider.fetchById(draft.id);

    // Pop and return true to refresh the previous screen
    Navigator.pop(context, true);
  }
}
