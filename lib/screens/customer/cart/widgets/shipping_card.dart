import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/address/provider.dart';
import '/features/address/domain/address.dart';

import '/screens/auth/auth_provider.dart';
import '/screens/customer/address/shipping_address_form.dart';
import '/screens/customer/address/change_address_dialogue.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAddress());
  }

  Future<void> _fetchAddress() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    await context.read<AddressProvider>().fetchShippingAddresses();
  }

  Future<void> _openAddressForm() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const ShippingAddressForm(),
      );

      if (result != null && mounted) await _fetchAddress();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectAddress() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final selected = await showGeneralDialog<Address>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Select Address',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => const ChangeAddressDialog(),
      );

      if (selected != null && mounted) {
        final provider = context.read<AddressProvider>();
        final remote = provider.repository;

        await remote.updateShippingAddress(selected);
        provider.setSelectedAddress(selected);
        await _fetchAddress();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<AddressProvider>(
          builder: (_, addressProv, _) {
            if (addressProv.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (addressProv.error != null) {
              return _ErrorCard(
                message: addressProv.error!,
                onRetry: _fetchAddress,
              );
            }

            final address =
                addressProv.selectedAddress ??
                (addressProv.addresses.isNotEmpty
                    ? addressProv.addresses.first
                    : null);

            return _AddressCard(
              address: address,
              onAddAddress: _isSaving ? null : _openAddressForm,
              onChangeAddress: _isSaving ? null : _selectAddress,
            );
          },
        ),

        // 🔹 Preloader overlay
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('⚠️ $message'),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address? address;
  final VoidCallback? onAddAddress;
  final VoidCallback? onChangeAddress;

  const _AddressCard({
    required this.address,
    required this.onAddAddress,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      onPressed: onAddAddress,
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
                    Text(address!.name, style: const TextStyle(fontSize: 16)),
                    Text('${address!.city}, ${address!.country}'),
                    Text(address!.phone),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onChangeAddress,
                        child: const Text('Change Address'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
