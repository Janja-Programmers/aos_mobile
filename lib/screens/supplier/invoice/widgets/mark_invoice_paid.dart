import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/domain/sales_order.dart';
import '/core/utils/snackbar.dart';

import '/features/order/prov.dart';

class PayInvoiceButton extends StatelessWidget {
  final SalesOrder order;

  const PayInvoiceButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SalesOrderProvider>();

    final isPaid = order.percentBilled >= 100;
    final isLoading = prov.detailLoading;

    return ElevatedButton(
      onPressed:
          (isPaid || isLoading)
              ? null
              : () => _payInvoice(context: context, order: order),
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
                      Icons.attach_money,
                      color: isPaid ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaid ? 'Paid' : 'Pay',
                      style: TextStyle(color: isPaid ? Colors.grey : null),
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _payInvoice({
    required BuildContext context,
    required SalesOrder order,
  }) async {
    final prov = context.read<SalesOrderProvider>();

    // 🔸 Extract required data
    final invoiceName = "ACC-SINV-${order.id}";
    final customerName = order.customerName;
    final amount = order.grandTotal;
    final referenceNo = "TXN-${DateTime.now().millisecondsSinceEpoch}";
    final referenceDate = DateTime.now().toIso8601String().split('T').first;

    final result = await prov.markInvoiceAsPaid(
      invoiceName: invoiceName,
      customerName: customerName,
      amount: amount,
      referenceNo: referenceNo,
      referenceDate: referenceDate,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Failed to mark invoice as paid",
        type: TopSnackType.error,
      ),
      (_) {
        topSnackBar(context, 'Invoice marked as paid');
        prov.fetchById(order.id);
      },
    );
  }
}

