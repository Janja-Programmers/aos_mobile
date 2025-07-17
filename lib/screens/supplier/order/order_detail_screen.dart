import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/order/domain/sales_order.dart';
import '/features/order/prov.dart';

import '/core/utils/snackbar.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';

import 'utils/print_order.dart';
import 'widgets/order_detail_item.dart';

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

  Future<void> _deliverOrder(SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.deliverOrder(order.id);

    if (!mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Error creating delivery note",
        type: TopSnackType.error,
      ),
      (_) => topSnackBar(context, ' Delivery Note created successfully'),
    );
  }

  Future<void> _billOrder(SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.billOrder(order.id);

    if (!mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Failed to bill Sales Order",
        type: TopSnackType.error,
      ),
      (_) => topSnackBar(context, 'Order billed successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesOrderProvider>();
    final order = provider.selectedOrder;

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: Text('Order Detail'),
      body: Builder(
        builder: (_) {
          if (provider.detailLoading || order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: Text(order.status)),
                    const SizedBox(width: 10),
                    Text(
                      'ID: ${order.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile(
                      'Grand Total',
                      order.grandTotal.toStringAsFixed(2),
                    ),
                    _infoTile('% Delivered', '${order.percentDelivered}%'),
                    _infoTile('% Billed', '${order.percentBilled}%'),
                  ],
                ),
                const SizedBox(height: 16),
                _actionButtons(order),
                const SizedBox(height: 24),
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: order.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder:
                        (_, i) => SalesOrderItemTile(item: order.items[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _actionButtons(SalesOrder order) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed:
              order.percentDelivered >= 100 ? null : () => _deliverOrder(order),
          icon: Icon(
            Icons.local_shipping_outlined,
            color: order.percentDelivered >= 100 ? Colors.grey : null,
          ),
          label: Text(
            order.percentDelivered >= 100 ? 'Delivered' : 'Deliver',
            style: TextStyle(
              color: order.percentDelivered >= 100 ? Colors.grey : null,
            ),
          ),
        ),

        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed:
              order.percentBilled >= 100 ? null : () => _billOrder(order),
          icon: Icon(
            Icons.receipt_long,
            color: order.percentBilled >= 100 ? Colors.grey : null,
          ),
          label: Text(
            order.percentBilled >= 100 ? 'Billed' : 'Bill',
            style: TextStyle(
              color: order.percentBilled >= 100 ? Colors.grey : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            printSalesOrder(order);
            topSnackBar(context, '🖨️ Printing...', type: TopSnackType.info);
          },
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
      ],
    );
  }
}
