import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/snackbar.dart';
import 'package:ownashop/features/order/domain/sales_order.dart';
import 'package:ownashop/features/order/prov.dart';
import 'package:provider/provider.dart';

import '../utils/print_order.dart';

class ActionButtonsCard extends StatelessWidget {
  final SalesOrder order;

  const ActionButtonsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    order.percentDelivered >= 100
                        ? null
                        : () => _deliverOrder(context, order),
                icon: Icon(
                  Icons.local_shipping_outlined,
                  color: order.percentDelivered >= 100 ? Colors.grey : null,
                ),
                label: Text(
                  order.percentDelivered >= 100 ? 'Delivered' : 'Deliver',
                  style: TextStyle(
                    color: order.percentDelivered >= 100 ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    order.percentBilled >= 100
                        ? null
                        : () => _billOrder(context, order),
                icon: Icon(
                  Icons.receipt_long,
                  color: order.percentBilled >= 100 ? Colors.grey : null,
                ),
                label: Text(
                  order.percentBilled >= 100 ? 'Billed' : 'Bill',
                  style: TextStyle(
                    color: order.percentBilled >= 100 ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  printSalesOrder(order);
                  topSnackBar(
                    context,
                    '🖨️ Printing...',
                    type: TopSnackType.info,
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deliverOrder(BuildContext context, SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.deliverOrder(order.id);

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Error creating delivery note",
        type: TopSnackType.error,
      ),
      (_) => topSnackBar(context, ' Delivery Note created successfully'),
    );
  }

  void _billOrder(BuildContext context, SalesOrder order) async {
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
}
