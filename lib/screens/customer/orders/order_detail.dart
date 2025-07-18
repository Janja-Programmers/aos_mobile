import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';
import '/shared/widgets/app_bars.dart';

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
    final String buyer = order['buyer'] ?? 'N/A';
    final String status = order['status'] ?? 'N/A';

    final double total = _parseToDouble(order['total']);

    final String date =
        order['date'] is String
            ? order['date']
            : formatCompactDateTime(order['date'] as DateTime);

    // Ensure items are List<Map<String, dynamic>>
    final List<Map<String, dynamic>> items =
        (order['items'] as List).map<Map<String, dynamic>>((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is String) {
            return {'name': item, 'qty': 1, 'rate': null, 'amount': null};
          } else {
            return {'name': '-', 'qty': 1, 'rate': null, 'amount': null};
          }
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 16)),
                Chip(
                  label: Text(status),
                  backgroundColor: Colors.orange[100],
                  labelStyle: TextStyle(color: Colors.orange[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                buyer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2.5),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Item',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              'Qty',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rate (Sh.)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Amount (Sh.)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ...items.map((item) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  item['name'] ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text('${item['qty'] ?? 1}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  item['rate'] != null
                                      ? _parseToDouble(
                                        item['rate'],
                                      ).toStringAsFixed(2)
                                      : '-',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                    const Divider(thickness: 1),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Grand Total: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sh ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
