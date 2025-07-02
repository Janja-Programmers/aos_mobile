import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/sales_order_tile.dart';

class SalesOrderListScreen extends StatefulWidget {
  const SalesOrderListScreen({super.key});

  @override
  State<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch orders on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesOrderProvider>().fetchAll();
    });
  }

  Future<void> _refresh() async {
    await context.read<SalesOrderProvider>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 5, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: 'Sales Order',
      body: Consumer<SalesOrderProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.failure != null) {
            return Center(
              child: Text(
                'Error: ${provider.failure!.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text('No sales orders found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return SalesOrderTile(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}
