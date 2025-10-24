import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/cart/provider.dart';

class PlaceOrderController {
  final BuildContext context;

  PlaceOrderController(this.context);

  /// Called when address is already selected (normal flow)
  Future<void> placeOrder({required String shippingAddress}) async {
    _showLoading();

    final cart = context.read<CartProvider>();

    final success = await cart.submitCartAsSalesOrder(
      shippingAddressName: shippingAddress,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog("Error placing order");
    }
  }

  // ──────────────────────────
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSuccessDialog() {
    topSnackBar(
      context,
      'Order placed successfully!',
      type: TopSnackType.success,
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Order Successful'),
            content: const Text(
              'Would you like to view your orders or continue shopping?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.push('/past-orders'),
                child: const Text('View Orders'),
              ),
              TextButton(
                onPressed: () => context.push('/'),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    topSnackBar(context, message, type: TopSnackType.error);
  }
}
