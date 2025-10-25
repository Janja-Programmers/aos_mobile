import 'package:flutter/material.dart';

import '/core/constants/colors.dart';

import '/features/order/domain/sales_order.dart';
import '/screens/supplier/order/widgets/product_table_card.dart';
import '/screens/supplier/order/widgets/so_info_card.dart';
import '/screens/supplier/order/widgets/print_order_button.dart';

import '/shared/widgets/app_bars.dart';

class CustomerSalesOrderDetailScreen extends StatelessWidget {
  final SalesOrder order;

  const CustomerSalesOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SalesOrderInfoCard(order: order),
            ProductTableCard(order: order),
          ],
        ),
      ),
      floatingActionButton: PrintSalesOrder(order: order),
    );
  }
}
