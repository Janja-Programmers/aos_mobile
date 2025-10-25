import 'package:africaonlinestores/screens/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '../utils/print_order.dart';

class PrintSalesOrder extends StatelessWidget {
  final dynamic order;
  const PrintSalesOrder({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: const Icon(Icons.print),
      onPressed: () {
        final username =
            context.read<AuthProvider>().user?.username ?? 'Unknown User';
        printSalesOrder(username: username, order: order);
        topSnackBar(context, '🖨️ Printing...', type: TopSnackType.info);
      },
    );
  }
}
