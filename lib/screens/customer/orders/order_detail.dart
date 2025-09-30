import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
import '/shared/widgets/app_bars.dart';

import '/screens/supplier/order/widgets/print_order_button.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final String status = order['status'] ?? 'N/A';
    final String orderId = order['id'] ?? 'N/A';

    final double total = _parseToDouble(order['total']);

    // Ensure items are List<Map<String, dynamic>>
    final List<Map<String, dynamic>> items =
        (order['items'] as List).map<Map<String, dynamic>>((item) {
          if (item is Map<String, dynamic>) return item;
          if (item is String) {
            return {'name': item, 'qty': 1, 'rate': null, 'amount': null};
          }
          return {'name': '-', 'qty': 1, 'rate': null, 'amount': null};
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🟢 Order Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text("Date"),
                        ],
                      ),
                    ),

                    // Right → order id + status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🟢 Items Table Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(30),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(1.5),
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                      ),
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('#'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('Item'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('Qty'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('Rate (Sh.)'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('Amount (Sh.)'),
                            ),
                          ],
                        ),

                        // Items
                        ...items.asMap().entries.map((entry) {
                          final i = entry.key + 1;
                          final item = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text('$i'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(item['name'] ?? '-'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text('${item['qty'] ?? 1}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  item['rate'] != null
                                      ? _parseToDouble(
                                        item['rate'],
                                      ).toStringAsFixed(2)
                                      : '-',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  item['amount'] != null
                                      ? _parseToDouble(
                                        item['amount'],
                                      ).toStringAsFixed(2)
                                      : '-',
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

                    // After the Table widget
                    const SizedBox(height: 12),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),

                    // 🟢 Grand Total Row (outside the table)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          total.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PrintSalesOrder(order: order),
    );
  }
}
