import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/prov.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/empty_state.dart';

import 'widgets/bill_order_button.dart';
import 'widgets/deliver_order_button.dart';
import 'widgets/so_info_card.dart';
import 'widgets/print_order_button.dart';
import 'widgets/product_table_card.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SalesOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
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
      body = const EmptyState(message: 'Error: Order not found');
    } else {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            SalesOrderInfoCard(order: order),
            ProductTableCard(order: order),
          ],
        ),
      );
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Order',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton:
          order != null
              ? (order.percentBilled < 100
                  ? BIllOrderButton(order: order)
                  : DeliverOrderButton(order: order))
              : null,
      body: body,
      floatingActionButton:
          order != null ? PrintSalesOrder(order: order) : null,
    );
  }
}
