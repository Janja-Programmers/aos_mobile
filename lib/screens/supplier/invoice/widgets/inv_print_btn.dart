import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';
import '../utils/print_invoice.dart';

class PrintSalesInvoice extends StatelessWidget {
  final dynamic order;
  const PrintSalesInvoice({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: const Icon(Icons.print),
      onPressed: () {
        printSalesInvoice(order);
        topSnackBar(context, '🖨️ Printing...', type: TopSnackType.info);
      },
    );
  }
}
