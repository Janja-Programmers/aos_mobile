import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/address/provider.dart';
import '/features/address/domain/address.dart';
import '/features/auth/presentation/auth_provider.dart';

class ShippingAddressForm extends StatefulWidget {
  const ShippingAddressForm({super.key});

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  final _formKey = GlobalKey<FormState>();

  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressLineController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAddress() async {
    if (_formKey.currentState?.validate() != true) return;

    final user = context.read<AuthProvider>().user!;
    final addressProv = context.read<AddressProvider>();

    final addressEntity = Address(
      name: '',
      title: user.username,
      line1: _addressLineController.text.trim(),
      city: _cityController.text.trim(),
      country: 'Kenya',
      phone: _phoneController.text.trim(),
      type: 'Shipping',
    );

    final name = await addressProv.createShippingAddress(addressEntity);

    if (!mounted) return;

    if (name != null) {
      context.pop(name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addressProv.error ?? 'Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AddressProvider>().isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Shipping Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressLineController,
                decoration: const InputDecoration(labelText: 'Address Line'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City/Town'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: isLoading ? null : _submitAddress,
                icon: const Icon(Icons.check),
                label: Text(isLoading ? 'Saving...' : 'Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
