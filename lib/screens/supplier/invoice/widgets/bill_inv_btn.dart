import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/domain/sales_order.dart';
import '/core/utils/snackbar.dart';

import '/features/d_note/prov.dart';

import '/features/order/prov.dart';

class BIllInvoiceButton extends StatelessWidget {
  final SalesOrder order;

  const BIllInvoiceButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          order.percentBilled >= 100
              ? null
              : () => _billInvoice(context, order),
      icon: Icon(
        Icons.receipt_long_outlined,
        color: order.percentBilled >= 100 ? Colors.grey : null,
      ),
      label: Text(
        order.percentBilled >= 100 ? 'Billed' : 'Bill',
        style: TextStyle(
          color: order.percentBilled >= 100 ? Colors.grey : null,
        ),
      ),
    );
  }

  void _billInvoice(BuildContext context, SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();

    // 🔹 Pass the Sales Order ID, not the DN ID
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
        context.read<DeliveryNoteProvider>().fetchAll();
      },
    );
  }
}
