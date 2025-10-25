import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/auth/auth_provider.dart';
import '/core/utils/snackbar.dart';

import '../utils/print_invoice.dart';

class PrintSalesInvoice extends StatelessWidget {
  final dynamic invoice;
  const PrintSalesInvoice({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: const Icon(Icons.print),
      onPressed: () async {
        final username = context.read<AuthProvider>().user?.username ?? 'Guest';
        topSnackBar(context, '🖨️ Printing...');
        await printSalesInvoice(username: username, invoice: invoice);
      },
    );
  }
}
