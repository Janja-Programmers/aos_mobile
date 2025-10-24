import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/features/address/provider.dart';

import '/screens/auth/auth_provider.dart';
import '/screens/customer/address/shipping_address_form.dart';

import '../controllers/place_order.dart';

class PaymentSummaryCard extends StatefulWidget {
  final double total;
  final PlaceOrderController controller;

  const PaymentSummaryCard({
    super.key,
    required this.total,
    required this.controller,
  });

  @override
  State<PaymentSummaryCard> createState() => _PaymentSummaryCardState();
}

class _PaymentSummaryCardState extends State<PaymentSummaryCard> {
  bool _isPlacingOrder = false;

  Future<void> _handlePlaceOrder(BuildContext context) async {
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);

    final addressProvider = context.read<AddressProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      setState(() => _isPlacingOrder = false);
      return;
    }

    // Always refresh, but keep current selection
    final previouslySelected = addressProvider.selectedAddress;
    await addressProvider.fetchShippingAddresses();

    // Restore selection if the provider didn’t preserve it
    final selectedAddress =
        addressProvider.selectedAddress ??
        (previouslySelected != null
            ? addressProvider.addresses.firstWhere(
              (a) => a.name == previouslySelected.name,
              orElse: () => addressProvider.addresses.first,
            )
            : addressProvider.addresses.firstOrNull);

    if (selectedAddress == null) {
      // ❌ No address → warn & open form, but DO NOT place order
      topSnackBar(
        context,
        'No shipping address found. Please add one first.',
        type: TopSnackType.error,
      );

      await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const ShippingAddressForm(),
      );

      // Refresh after user attempts to add
      await addressProvider.fetchShippingAddresses();

      // ✅ Still do not place order here. User must tap again.
      setState(() => _isPlacingOrder = false);
      return;
    }

    // ✅ Use the actual selected address
    await widget.controller.placeOrder(shippingAddress: selectedAddress.name);

    setState(() => _isPlacingOrder = false);
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
              'Grand Total: Sh ${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isPlacingOrder ? null : () => _handlePlaceOrder(context),
                child:
                    _isPlacingOrder
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
