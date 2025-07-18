import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/prov.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';

import 'widgets/action_buttons_card.dart';
import 'widgets/customer_card.dart';
import 'widgets/order_summary_card.dart';
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
            'Sales Order / ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            order?.id ?? '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (provider.detailLoading || order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ListView(
              children: [
                CustomerCard(order: order),
                OrderSummaryCard(order: order),
                ActionButtonsCard(order: order),
                ProductTableCard(order: order),
              ],
            ),
          );
        },
      ),
    );
  }
}
