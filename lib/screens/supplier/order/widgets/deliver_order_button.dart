import 'package:flutter/material.dart';
import '/core/utils/snackbar.dart';
import '/features/order/domain/sales_order.dart';
import '/features/order/prov.dart';
import 'package:provider/provider.dart';

class DeliverOrderButton extends StatelessWidget {
  final SalesOrder order;

  const DeliverOrderButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          order.percentDelivered >= 100
              ? null
              : () => _deliverOrder(context, order),
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
      (_) => topSnackBar(context, ' Delivery Note created successfully'),
    );
  }
}
