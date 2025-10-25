import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/order/domain/sales_order.dart';
import '/features/order/prov.dart';

class DeliverOrderButton extends StatelessWidget {
  final SalesOrder order;

  const DeliverOrderButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SalesOrderProvider>();
    final isDelivered = order.percentDelivered >= 100;
    final isLoading = prov.detailLoading;

    return ElevatedButton(
      onPressed:
          (isDelivered || isLoading)
              ? null
              : () => _deliverOrder(context, order),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder:
            (child, anim) => FadeTransition(opacity: anim, child: child),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: isDelivered ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDelivered ? 'Delivered' : 'Deliver',
                      style: TextStyle(color: isDelivered ? Colors.grey : null),
                    ),
                  ],
                ),
      ),
    );
  }

  void _deliverOrder(BuildContext context, SalesOrder order) async {
    final prov = context.read<SalesOrderProvider>();
    final result = await prov.deliverOrder(order.id);

    if (!context.mounted) return;

    result.fold(
      (failure) => topSnackBar(
        context,
        "Error creating delivery note",
        type: TopSnackType.error,
      ),
      (_) async {
        topSnackBar(context, 'Delivery Note created successfully');

        context.push('/sales-orders');

        // 🔹 Optional: refresh sales orders first
        context.read<SalesOrderProvider>().fetchAll();
      },
    );
  }
}
