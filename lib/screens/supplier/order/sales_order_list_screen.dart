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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesOrderProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<SalesOrderProvider>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: const Text(
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
                  const Text(
                    'Error: Could not load orders',
                    style: TextStyle(color: Colors.red),
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

          // 🔍 Filter by search
          final query = _searchController.text.trim().toLowerCase();
          final filteredOrders =
              provider.orders.where((order) {
                return query.isEmpty ||
                    order.customerName.toLowerCase().contains(query) ||
                    order.status.toLowerCase().contains(query) ||
                    order.id.toLowerCase().contains(query);
              }).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  // 🔍 Search bar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search by customer, status, or order ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  // Orders list
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 2,
                    child: Column(
                      children:
                          filteredOrders.isEmpty
                              ? [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),

                                  child: Text(
                                    "No sales orders match your search.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                              : filteredOrders
                                  .map(
                                    (order) => Column(
                                      children: [
                                        SalesOrderCardRow(order: order),
                                        const Divider(
                                          height: 2,
                                          color: AppColors.background,
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
