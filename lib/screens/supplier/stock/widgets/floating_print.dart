import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';
import '../utils/print_stock_entry.dart';

class PrintSO extends StatelessWidget {
  final dynamic entry;
  const PrintSO({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Only show FAB if docstatus is submitted
    if (entry.docstatus != 1) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: const Icon(Icons.print),
      onPressed: () {
        printStockIntake(context, entry);
        topSnackBar(context, '🖨️ Printing...', type: TopSnackType.info);
      },
    );
  }
}
