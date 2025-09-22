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

    // Inside build:
    final query = _searchController.text.trim().toLowerCase();
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
          // 🔍 Search field with controller + consistent padding
          Padding(
            padding: const EdgeInsets.all(12), // ✅ same margin all around
            child: TextField(
              controller: _searchController, // ✅ attach controller
              decoration: InputDecoration(
                hintText: 'Search past orders by name, id, or status',
                prefixIcon: const Icon(Icons.search),
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onChanged: (_) {
                if (debounce?.isActive ?? false) debounce!.cancel();
                debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
            ),
          ),

          // Orders list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.fetchOrders();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
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

                              return InkWell(
                                onTap: () {
                                  context.push('/order-detail', extra: order);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Left: Item name + id
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getFirstItemName(order['items']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              order['id'],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Right: status chip
                                      Chip(
                                        label: Text(order['status']),
                                        backgroundColor: Colors.orange[100],
                                        labelStyle: TextStyle(
                                          color: Colors.orange[800],
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
