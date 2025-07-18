import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
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
      final provider = context.read<CustomerOrderProvider>();
      provider.fetchOrders();
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String getFirstItemName(dynamic items) {
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map<String, dynamic>) return first['name'] ?? 'Item';
      if (first is String) return first;
    }
    return 'Item';
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

    final query = _searchController.text.toLowerCase();
    final filteredOrders =
        provider.orders.where((order) {
          final items = (order['items'] ?? []).join(' ').toLowerCase();
          final id = (order['id'] ?? '').toString().toLowerCase();
          final buyer = (order['buyer'] ?? '').toString().toLowerCase();
          final status = (order['status'] ?? '').toString().toLowerCase();

          return query.isEmpty ||
              items.contains(query) ||
              id.contains(query) ||
              buyer.contains(query) ||
              status.contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search past orders by name',
                prefixIcon: const Icon(Icons.search),
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),

              onChanged: (value) {
                if (debounce?.isActive ?? false) debounce!.cancel();
                debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Orders list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filteredOrders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];

                  return InkWell(
                    onTap: () {
                      context.push('/order-detail', extra: order);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item name (highlighted)
                            Text(
                              getFirstItemName(order['items']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Order ID as subtitle
                            Text(
                              order['id'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            // Bottom Row: date, status, total
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order['date'] is String
                                        ? order['date']
                                        : formatCompactDateTime(
                                          order['date'] as DateTime,
                                        ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Chip(
                                  label: Text(order['status']),
                                  backgroundColor: Colors.orange[100],
                                  labelStyle: TextStyle(
                                    color: Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Sh ${order['total']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
