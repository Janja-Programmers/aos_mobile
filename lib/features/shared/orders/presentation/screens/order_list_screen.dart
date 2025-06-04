import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../order_provider.dart';
import '../widgets/order_item_widget.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: RefreshIndicator(
        onRefresh: orderProvider.fetchOrders,
        child: ListView.builder(
          itemCount: orderProvider.orders.length,
          itemBuilder: (_, i) {
            final order = orderProvider.orders[i];
            return OrderItemWidget(
              order: order,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
