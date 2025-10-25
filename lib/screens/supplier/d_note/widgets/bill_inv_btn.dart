import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/features/d_note/domain/entity/delivery_note.dart';
import '/features/d_note/prov.dart';
import '/features/order/prov.dart';

class BillInvoiceButton extends StatelessWidget {
  final DeliveryNote note;

  const BillInvoiceButton({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SalesOrderProvider>();
    final isBilled = note.percentInstalled >= 100;
    final isLoading = prov.detailLoading;

    return ElevatedButton(
      onPressed:
          (isBilled || isLoading) ? null : () => _billInvoice(context, note),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder:
            (child, anim) => FadeTransition(opacity: anim, child: child),
        child:
            isLoading
                ? const SizedBox(
                  width: 18,
                  height: 18,
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
                      size: 18,
                      color: isBilled ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBilled ? 'Billed' : 'Bill',
                      style: TextStyle(
                        color: isBilled ? Colors.grey : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _billInvoice(BuildContext context, DeliveryNote note) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.billOrder(note.id);

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Failed to bill Sales Order",
        type: TopSnackType.error,
      ),
      (_) {
        topSnackBar(context, 'Sales Invoice created successfully');
        context.push('/delivery-notes');
        context.read<DeliveryNoteProvider>().fetchAll();
      },
    );
  }
}
