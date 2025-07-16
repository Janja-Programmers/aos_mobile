import 'package:flutter/material.dart';
import 'package:ownashop/screens/customer/address/shipping_address_form.dart';

import '../controllers/place_order.dart';

class ShippingAddressCard extends StatelessWidget {
  final PlaceOrderController controller;

  const ShippingAddressCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () => ShippingAddressForm(),
              child: const Text('Add New Address'),
            ),
          ],
        ),
      ),
    );
  }
}
