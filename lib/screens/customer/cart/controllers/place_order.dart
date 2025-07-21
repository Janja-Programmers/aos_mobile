import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/provider.dart';

import '/screens/customer/address/shipping_address_form.dart';

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
      await cart.submitCartAsSalesOrder(shippingAddressName: name);
      if (context.mounted) Navigator.of(context).pop();
      _showSuccessDialog();
    }
  }

  /// Called when address is already selected (normal flow)
  Future<void> placeOrder({required String shippingAddress}) async {
    _showLoading();

    try {
      await context.read<CartProvider>().submitCartAsSalesOrder(
        shippingAddressName: shippingAddress,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      _showSuccessDialog();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      String message = 'Failed to place order. Please try again.';
      bool shouldClearCart = false;

      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map &&
            data['exception']?.toString().contains('MandatoryError') == true &&
            data['exception']?.toString().contains('customer') == true) {
          message = 'Vendors cannot place orders';
          shouldClearCart = true;
        }
      }

      if (shouldClearCart) {
        await context.read<CartProvider>().clear();
      }

      topSnackBar(context, message, type: TopSnackType.error);
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
                onPressed: () => context.go('/orders'),
                child: const Text('View Orders'),
              ),
              TextButton(
                onPressed: () => context.go('/'),
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
