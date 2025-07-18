import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/address/provider.dart';
import '/features/auth/presentation/auth_provider.dart';
import '/screens/customer/address/shipping_address_form.dart';

import '../controllers/place_order.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double total;
  final PlaceOrderController controller;

  const PaymentSummaryCard({
    super.key,
    required this.total,
    required this.controller,
  });

  Future<void> _handlePlaceOrder(BuildContext context) async {
    final addressProvider = context.read<AddressProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) return;

    await addressProvider.fetchShippingAddresses();

    final hasShippingAddress = addressProvider.addresses.isNotEmpty;

    if (!hasShippingAddress) {
      // Show warning
      topSnackBar(
        context,
        'Please add a shipping address first.',
        type: TopSnackType.error,
      );

      // Launch address form modal
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const ShippingAddressForm(),
      );

      // If user saved an address, refresh and re-validate
      if (result != null) {
        await addressProvider.fetchShippingAddresses();
        if (addressProvider.addresses.isNotEmpty) {
          controller.placeOrder();
        }
      }

      return;
    }

    // Proceed if address exists
    controller.placeOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Grand Total: Sh ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePlaceOrder(context),
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
