import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/prov.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/empty_state.dart';

import 'widgets/inv_info_card.dart';
import 'widgets/inv_print_btn.dart';
import 'widgets/mark_invoice_paid.dart';
import 'widgets/product_table_card.dart';

class SalesInvoiceDetailScreen extends StatefulWidget {
  final String orderId;

  const SalesInvoiceDetailScreen({super.key, required this.orderId});

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
      context.read<SalesOrderProvider>().fetchById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesOrderProvider>();
    final order = provider.selectedOrder;

    Widget body;

    if (provider.detailLoading) {
      body = const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else if (order == null) {
      body = const EmptyState(message: 'Error: Invoice not found');
    } else {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            SalesInvoiceInfoCard(order: order),
            InvoiceTableCard(order: order),
          ],
        ),
      );
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Invoice',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton:
          order != null && order.percentBilled >= 100
              ? PayInvoiceButton(order: order)
              : null,
      body: body,
      floatingActionButton:
          order != null ? PrintSalesInvoice(order: order) : null,
    );
  }
}
