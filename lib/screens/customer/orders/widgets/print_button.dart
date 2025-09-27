import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';

import '/features/order/domain/sales_order.dart';

import '../utils/print_orders.dart';

class PrintButton extends StatelessWidget {
  final SalesOrder order;
  const PrintButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: const Icon(Icons.print),
      onPressed: () {
        printSalesOrder(context, order); // 👈 still works
        topSnackBar(context, '🖨️ Printing...', type: TopSnackType.info);
      },
    );
  }
}
