import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';

import '/features/order/domain/sales_order.dart';
import '/shared/widgets/app_bars.dart';

import '/screens/supplier/order/widgets/print_order_button.dart';

class CustomerSalesOrderDetailScreen extends StatelessWidget {
  final SalesOrder order;

  const CustomerSalesOrderDetailScreen({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'to bill':
      case 'to deliver':
        return AppColors.warning.withOpacity(0.2);
      case 'completed':
        return AppColors.success.withOpacity(0.2);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'awaiting':
        return AppColors.warning;
      case 'processing':
      case 'in progress':
        return AppColors.info;
      case 'completed':
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
      case 'rejected':
        return AppColors.danger;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = order.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🟢 Order Info
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
                    // Order ID & Customer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order Date: ${formatCompactDateTime(order.deliveryDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    // 🟡 Status Chip
                    Chip(
                      label: Text(
                        order.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(order.status),
                        ),
                      ),
                      backgroundColor: _getStatusColor(order.status),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            // 🟢 Items Table
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
                        // Header
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

                        // Rows
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
                                child: Text(item.itemName),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text('${item.qty}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(formatCurrency(item.rate)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(formatCurrency(item.amount)),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),

                    // 🧾 Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatCurrency(order.grandTotal),
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
