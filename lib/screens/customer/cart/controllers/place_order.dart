import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/data/remote.dart';
import '/features/cart/provider.dart';

import '/screens/customer/address/shipping_address_form.dart';

class PlaceOrderController {
  final BuildContext context;

  PlaceOrderController(this.context);

  Future<void> createAdress() async {
    final cart = context.read<CartProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      _showErrorDialog('You must be logged in to place an order.');
      return;
    }

    _showLoading();

    await cart.submitCartWithAutoAddress(
      customer: user.username,
      openShippingForm: () async {
        Navigator.of(context).pop(); // Close loading dialog before bottom sheet

        final name = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => const ShippingAddressForm(),
        );

        if (name != null) {
          _showLoading();
          await cart.submitCartAsSalesOrder(shippingAddressName: name);
          Navigator.of(context).pop(); // Close loading
        }
      },
      onSuccess: (addressUsed) {
        Navigator.of(context).pop();
        _showSuccessDialog();
      },
    );
  }

  Future<void> placeOrder() async {
    _showLoading();

    try {
      final orderService = OrderService(sl<APIClient>());

      await orderService.placeOrder();

      if (!context.mounted) return;
      Navigator.of(context).pop();

      // ✅ Clear the cart
      final cartProvider = context.read<CartProvider>();
      await cartProvider.clear();

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      String message = 'Failed to place order. Please try again.';
      bool shouldClearCart = false;

      if (e is DioException) {
        final data = e.response?.data;

        // Check for missing customer (vendor case)
        if (data is Map &&
            data['exception']?.toString().contains('MandatoryError') == true &&
            data['exception']?.toString().contains('customer') == true) {
          message = 'Vendors cannot place orders';
          shouldClearCart = true;
        }
      }

      // ✅ Clear the cart if needed
      if (shouldClearCart) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.clear();
      }

      // ✅ Show error via topSnackbar
      topSnackBar(context, message, type: TopSnackType.error);
    }
  }

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
