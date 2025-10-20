import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/domain/sales_order.dart';
import '/features/order/prov.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/empty_state.dart';

import 'widgets/deliver_order_button.dart';
import 'widgets/so_info_card.dart';
import 'widgets/print_order_button.dart';
import 'widgets/product_table_card.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SalesOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SalesOrderProvider>().fetchById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesOrderProvider>();
    final order = provider.selectedOrder;

    Widget body;

    if (provider.detailLoading) {
      body = const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else if (order == null) {
      body = const EmptyState(message: 'Error: Order not found');
    } else {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            SalesOrderInfoCard(order: order),
            ProductTableCard(order: order),
          ],
        ),
      );
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Order',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton: _buildActionButton(order),
      body: body,
      floatingActionButton:
          order != null ? PrintSalesOrder(order: order) : null,
    );
  }

  Widget _buildActionButton(SalesOrder? order) {
    if (order == null) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty, color: Colors.grey),
        label: const Text('Loading...', style: TextStyle(color: Colors.grey)),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey,
        ),
      );
    }

    final status = order.status.toLowerCase();

    switch (status) {
      case 'delivered':
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.local_shipping_outlined, color: Colors.grey),
          label: const Text('Delivered', style: TextStyle(color: Colors.grey)),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey,
          ),
        );

      case 'cancelled':
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          label: const Text(
            'Cancelled',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.red,
          ),
        );

      default:
        return DeliverOrderButton(order: order);
    }
  }
}
