import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/cart/provider.dart';

import '/screens/customer/address/shipping_address_form.dart';
import '/screens/auth/auth_provider.dart';

class PlaceOrderController {
  final BuildContext context;

  PlaceOrderController(this.context);

  /// If no address selected, prompt user to create one before proceeding
  Future<void> createAddressAndPlaceOrder() async {
    final cart = context.read<CartProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      _showErrorDialog('You must be logged in to place an order.');
      return;
    }

    // 🔄 Show loading while checking/creating address
    _showLoading();

    Navigator.of(context).pop();

    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ShippingAddressForm(),
    );

    if (name != null) {
      _showLoading();
      final success = await cart.submitCartAsSalesOrder(
        shippingAddressName: name,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (success) {
        _showSuccessDialog();
      } else {
        topSnackBar(
          context,
          'Failed to place order. Please try again.',
          type: TopSnackType.error,
        );
      }
    }
  }

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
      topSnackBar(
        context,
        'Failed to place order. Please try again.',
        type: TopSnackType.error,
      );
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
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
