import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/d_note/domain/entity/delivery_note.dart';
import '/features/d_note/prov.dart';

import '/features/order/prov.dart';

class BIllOrderButton extends StatelessWidget {
  final DeliveryNote order;

  const BIllOrderButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          order.percentInstalled >= 100
              ? null
              : () => _billOrder(context, order),
      icon: Icon(
        Icons.receipt_long_outlined,
        color: order.percentInstalled >= 100 ? Colors.grey : null,
      ),
      label: Text(
        order.percentInstalled >= 100 ? 'Billed' : 'Bill',
        style: TextStyle(
          color: order.percentInstalled >= 100 ? Colors.grey : null,
        ),
      ),
    );
  }

  void _billOrder(BuildContext context, DeliveryNote order) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.billOrder(order.id);

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Failed to bill Sales Order",
        type: TopSnackType.error,
      ),
      (_) {
        topSnackBar(context, 'Order billed successfully');

        // 🔹 Refresh the sales order list too
        context.read<DeliveryNoteProvider>().fetchAll();
      },
    );
  }
}
