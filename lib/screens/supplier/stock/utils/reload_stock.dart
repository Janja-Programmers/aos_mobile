import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/read.dart';

Future<void> reloadStockEntry(BuildContext context, StockEntry entry) async {
  final detailProvider = context.read<StockEntryDetailProvider>();

  await detailProvider.fetchById(entry.id);

  if (!context.mounted) return;

  if (detailProvider.hasError) {
    topSnackBar(
      context,
      detailProvider.failure!.message,
      type: TopSnackType.error,
    );
  } else {
    topSnackBar(
      context,
      'Stock Entry reloaded successfully',
      type: TopSnackType.success,
    );
  }
}
