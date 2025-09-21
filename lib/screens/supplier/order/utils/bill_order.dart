import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/order/domain/sales_order.dart';
import '/features/order/prov.dart';

void billOrder(BuildContext context, SalesOrder order) async {
  final prov = context.read<SalesOrderProvider>();
  final result = await prov.billOrder(order.id);

  if (!context.mounted) return;

  result.fold(
    (failure) => topSnackBar(
      context,
      "Failed to bill Sales Order",
      type: TopSnackType.error,
    ),
    (_) => topSnackBar(context, 'Order billed successfully'),
  );
}
