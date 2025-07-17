import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/order/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/so_card_row.dart';

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
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: Text(
        'Sales Order',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Consumer<SalesOrderProvider>(
        builder: (context, provider, _) {
          if (provider.listLoading) {
            return const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          if (provider.failure != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: Could not load orders',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _refresh,
                  ),
                ],
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                elevation: 2,
                child: Column(
                  children:
                      provider.orders.map((order) {
                        return Column(
                          children: [
                            SalesOrderCardRow(order: order),
                            const Divider(
                              height: 2,
                              color: AppColors.background,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
