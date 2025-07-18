import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/snackbar.dart';
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
    topSnackBar(context, provider.failure!.message, type: TopSnackType.error);
  } else {
    topSnackBar(
      context,
      'Stock Entry submitted successfully',
      type: TopSnackType.success,
    );

    // Refresh detail
    await detailProvider.fetchById(draft.id);
  }
}
