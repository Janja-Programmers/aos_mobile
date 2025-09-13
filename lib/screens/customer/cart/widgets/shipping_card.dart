import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/address/provider.dart';
import '../../../auth/auth_provider.dart';
import '/features/address/domain/address.dart';

import '/screens/customer/address/shipping_address_form.dart';

import '../../address/change_address_dialogue.dart';

import '../controllers/place_order.dart';

class ShippingAddressCard extends StatefulWidget {
  final PlaceOrderController controller;

  const ShippingAddressCard({super.key, required this.controller});

  @override
  State<ShippingAddressCard> createState() => _ShippingAddressCardState();
}

class _ShippingAddressCardState extends State<ShippingAddressCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchAddress());
  }

  Future<void> _fetchAddress() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context.read<AddressProvider>().fetchShippingAddresses();
    }
  }

  Future<void> _openAddressForm() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ShippingAddressForm(),
    );

    if (result != null) {
      await _fetchAddress();
    }
  }

  Future<void> _selectAddress() async {
    final selected = await showGeneralDialog<Address>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Select Address',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => const ChangeAddressDialog(),
    );

    if (selected != null) {
      final provider = context.read<AddressProvider>();
      final remote = provider.repository;

      await remote.updateShippingAddress(selected);

      // 🩹 SET selected address locally to update UI
      provider.setSelectedAddress(selected); // ✅ Add this line

      await _fetchAddress(); // refresh from backend (optional)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (_, addressProv, _) {
        if (addressProv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addressProv.error != null) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('⚠️ ${addressProv.error!}'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _fetchAddress,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final address =
            addressProv.selectedAddress ?? addressProv.addresses.firstOrNull;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                address == null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'No Shipping Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _openAddressForm,
                          child: const Text('Add Address'),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address.title,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(address.line1),
                        Text('${address.city}, ${address.country}'),
                        Text('📞 ${address.phone}'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _selectAddress();
                            },
                            child: const Text('Change Address'),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
