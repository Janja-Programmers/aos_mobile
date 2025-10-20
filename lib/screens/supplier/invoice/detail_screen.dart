import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/invoice/prov.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/disabled_btn.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/invoice_info_card.dart';
import 'widgets/inv_print_btn.dart';
import 'widgets/mark_invoice_paid.dart';
import 'widgets/invoice_product_table_card.dart';

class SalesInvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const SalesInvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<SalesInvoiceDetailScreen> createState() =>
      _SalesInvoiceDetailScreenState();
}

class _SalesInvoiceDetailScreenState extends State<SalesInvoiceDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SalesInvoiceProvider>().fetchById(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesInvoiceProvider>();
    final invoice = provider.selectedinvoice;

    Widget body;

    if (provider.detailLoading) {
      body = const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else if (invoice == null) {
      body = const EmptyState(message: 'Error: Invoice not found');
    } else {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            SalesInvoiceInfoCard(invoice: invoice),
            InvoiceTableCard(order: invoice),
          ],
        ),
      );
    }

    // Determine action button
    Widget? actionButton;
    if (invoice != null) {
      final status = invoice.status.toLowerCase();
      if (status != 'paid' && status != 'cancelled') {
        // Show action button when not paid/cancelled
        actionButton = PayInvoiceButton(invoice: invoice);
      } else {
        // Show disabled button labeled with the current status
        actionButton = buildDisabledButton(
          label: status[0].toUpperCase() + status.substring(1),
          icon: status == 'paid' ? Icons.check_circle : Icons.cancel,
          color: status == 'paid' ? Colors.green : Colors.red,
        );
      }
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Invoice',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton: actionButton,
      body: body,
      floatingActionButton:
          invoice != null ? PrintSalesInvoice(order: invoice) : null,
    );
  }
}
