import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/prov.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';

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

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: Row(
        children: [
          Text(
            'Sales Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actionButton: DeliverOrderButton(order: order!),
      body: Builder(
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ListView(
              children: [
                SalesOrderInfoCard(order: order),
                ProductTableCard(order: order),
              ],
            ),
          );
        },
      ),
      floatingActionButton: PrintSalesOrder(order: order),
    );
  }
}
