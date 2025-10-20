import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/features/invoice/domain/sales_invoice.dart';
import '/features/invoice/prov.dart';

class PayInvoiceButton extends StatelessWidget {
  final SalesInvoice invoice;

  const PayInvoiceButton({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SalesInvoiceProvider>();

    // Use the refreshed invoice if available
    final currentInvoice =
        prov.selectedinvoice?.id == invoice.id ? prov.selectedinvoice : invoice;

    final isPaid = (currentInvoice?.outstandingAmount ?? 0) == 0;
    final isLoading = prov.detailLoading;

    return ElevatedButton(
      onPressed:
          (isPaid || isLoading)
              ? null
              : () => _payInvoice(context: context, invoice: invoice),
      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
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
                : Text(
                  isPaid ? 'Paid' : 'Mark as Paid',
                  style: TextStyle(color: isPaid ? Colors.grey : null),
                ),
      ),
    );
  }

  Future<void> _payInvoice({
    required BuildContext context,
    required SalesInvoice invoice,
  }) async {
    final prov = context.read<SalesInvoiceProvider>();

    final result = await prov.markInvoiceAsPaid(
      invoiceName: invoice.id,
      customerName: invoice.customerName,
      amount: invoice.grandTotal,
      referenceNo: "TXN-${DateTime.now().millisecondsSinceEpoch}",
      referenceDate: DateTime.now().toIso8601String().split('T').first,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Failed to mark invoice as paid",
        type: TopSnackType.error,
      ),
      (_) {
        topSnackBar(
          context,
          'Invoice ${invoice.id} marked as paid (${invoice.grandTotal.toStringAsFixed(2)})',
        );
        prov.fetchById(invoice.id);
      },
    );
  }
}
