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
    final prov = context.watch<SalesOrderProvider>();
    final isBilled = order.percentBilled >= 100;
    final isLoading = prov.detailLoading;

    return ElevatedButton(
      onPressed:
          (isBilled || isLoading) ? null : () => _billInvoice(context, order),
      style: ElevatedButton.styleFrom(minimumSize: const Size(140, 48)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder:
            (child, anim) => FadeTransition(opacity: anim, child: child),
        child:
            isLoading
                ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: isBilled ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBilled ? 'Billed' : 'Bill',
                      style: TextStyle(color: isBilled ? Colors.grey : null),
                    ),
                  ],
                ),
      ),
    );
  }

  void _billInvoice(BuildContext context, SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();

    // 🔹 Pass the Sales Order ID
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
