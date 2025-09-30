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
  bool _isSaving = false;

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
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ShippingAddressForm(),
    );

    if (result != null) {
      await _fetchAddress();
    }

    setState(() => _isSaving = false);
  }

  Future<void> _selectAddress() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

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

      provider.setSelectedAddress(selected);

      await _fetchAddress();
    }

    setState(() => _isSaving = false);
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            TextButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : _openAddressForm, // disabled while saving
                              child: const Text('Add Address'),
                            ),
                            if (_isSaving)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
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
                        Text(address.phone),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : TextButton(
                                    onPressed: _selectAddress,
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
