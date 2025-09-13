import 'package:flutter/material.dart';
import '/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/address/domain/address.dart';
import '/features/address/provider.dart';

import 'shipping_address_form.dart';

class ChangeAddressDialog extends StatefulWidget {
  const ChangeAddressDialog({super.key});

  @override
  State<ChangeAddressDialog> createState() => _ChangeAddressDialogState();
}

class _ChangeAddressDialogState extends State<ChangeAddressDialog> {
  String? selectedAddressName;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AddressProvider>();
    selectedAddressName = provider.selectedAddress?.name;
    if (provider.addresses.isEmpty) {
      provider.fetchShippingAddresses();
    }
  }

  Future<void> _openAddressForm({Address? initialData}) async {
    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Address Form',
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ShippingAddressForm(initialData: initialData),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );

    if (result != null) {
      final addressProv = context.read<AddressProvider>();
      await addressProv.fetchShippingAddresses();

      // ✅ Show SnackBar if message exists
      if (addressProv.message != null) {
        topSnackBar(context, addressProv.message!);
        addressProv.clearStatus();
      }

      setState(() {
        selectedAddressName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Consumer<AddressProvider>(
            builder: (context, provider, _) {
              final addresses = provider.addresses;
              final isLoading = provider.isLoading;

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (addresses.isEmpty)
                      const Text('No addresses found.')
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: addresses.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final addr = addresses[index];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Radio<String>(
                                value: addr.name,
                                groupValue: selectedAddressName,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAddressName = value;
                                  });
                                },
                              ),
                              title: Text(addr.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(addr.line1),
                                  Text('${addr.city}, ${addr.country}'),
                                  Text('📞 ${addr.phone}'),
                                ],
                              ),
                              trailing: TextButton(
                                onPressed:
                                    () => _openAddressForm(initialData: addr),
                                child: const Text('Edit'),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedAddressName = addr.name;
                                });
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _openAddressForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed:
                          selectedAddressName == null
                              ? null
                              : () {
                                Navigator.of(context).pop(
                                  provider.addresses.firstWhere(
                                    (a) => a.name == selectedAddressName,
                                  ),
                                );
                              },
                      child: const Text('Use This Address'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
