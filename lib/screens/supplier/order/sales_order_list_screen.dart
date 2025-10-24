import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/features/order/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/error_state.dart';
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
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Orders',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Consumer<SalesOrderProvider>(
        builder: (context, provider, _) {
          // Loading state
          if (provider.listLoading) {
            return const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          // Failure state
          if (provider.failure != null) {
            return ErrorState(
              resource: 'sales orders.',
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          // Filter by search
          final query = _searchController.text.trim().toLowerCase();
          final filteredOrders =
              provider.orders.where((order) {
                return query.isEmpty ||
                    order.customerName.toLowerCase().contains(query) ||
                    order.status.toLowerCase().contains(query) ||
                    order.id.toLowerCase().contains(query);
              }).toList();

          // No orders at all
          if (provider.orders.isEmpty) {
            return EmptyState(message: 'No sales orders found.');
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by customer, ID, or status',
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

                // Card with list
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with count
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sales Orders",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${filteredOrders.length} of ${provider.orders.length}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          height: 0,
                          thickness: 1.2,
                          color: AppColors.background,
                        ),

                        // List
                        Expanded(
                          child:
                              filteredOrders.isEmpty
                                  ? EmptyState(
                                    message:
                                        'No sales orders match your search.',
                                    actionLabel: 'Clear search',
                                    onAction: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                  : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: filteredOrders.length,
                                    separatorBuilder:
                                        (_, _) => const Divider(
                                          height: 0.5,
                                          thickness: 0.5,
                                        ),
                                    itemBuilder: (_, i) {
                                      final order = filteredOrders[i];
                                      return SalesOrderCardRow(order: order);
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
