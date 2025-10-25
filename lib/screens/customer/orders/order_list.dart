import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/shared/widgets/app_bars.dart';

import 'provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Timer? debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerOrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerOrderProvider>();

    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: Center(child: Text(provider.error!)),
      );
    }

    final query = _searchController.text.trim().toLowerCase();

    // ✅ Use typed filtering
    final filteredOrders =
        provider.orders.where((order) {
          final itemsText = order.items
              .map((i) => i.itemName.toLowerCase())
              .join(' ');
          return query.isEmpty ||
              order.id.toLowerCase().contains(query) ||
              order.status.toLowerCase().contains(query) ||
              order.customerName.toLowerCase().contains(query) ||
              itemsText.contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by order ID, item, or status',
                prefixIcon: const Icon(Icons.search),
                fillColor: AppColors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
            ),
          ),

          // 📋 Orders
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchOrders,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child:
                      filteredOrders.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                "No orders match your search.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                          : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredOrders.length,
                            separatorBuilder:
                                (_, _) => const Divider(height: 2),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final firstItem =
                                  order.items.isNotEmpty
                                      ? order.items.first.itemName
                                      : 'Item';

                              // 🎨 Status chip colors
                              late Color statusColor;
                              late Color statusTextColor;

                              switch (order.status.toLowerCase()) {
                                case 'completed':
                                  statusColor = AppColors.success.withOpacity(
                                    0.2,
                                  );
                                  statusTextColor = AppColors.success;
                                  break;

                                case 'to deliver':
                                case 'to bill':
                                  statusColor = const Color.fromARGB(
                                    255,
                                    154,
                                    153,
                                    147,
                                  ).withOpacity(0.2);
                                  statusTextColor = const Color.fromARGB(
                                    255,
                                    33,
                                    33,
                                    32,
                                  );
                                  break;
                                case 'to deliver and bill':
                                  statusColor = AppColors.warning.withOpacity(
                                    0.2,
                                  );
                                  statusTextColor = const Color.fromARGB(
                                    255,
                                    255,
                                    119,
                                    7,
                                  );
                                  break;

                                case 'cancelled':
                                case 'rejected':
                                  statusColor = AppColors.danger.withOpacity(
                                    0.2,
                                  );
                                  statusTextColor = AppColors.danger;
                                  break;

                                case 'processing':
                                case 'in progress':
                                  statusColor = AppColors.info.withOpacity(0.2);
                                  statusTextColor = AppColors.info;
                                  break;

                                default:
                                  statusColor = Colors.grey.shade200;
                                  statusTextColor = Colors.grey.shade700;
                              }

                              return InkWell(
                                onTap:
                                    () => context.push(
                                      '/order-detail',
                                      extra: order,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order.id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              firstItem,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Chip(
                                        label: Text(order.status),
                                        backgroundColor: statusColor,
                                        labelStyle: TextStyle(
                                          color: statusTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
