import 'package:flutter/material.dart';

class ProductActionButtons extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onContact;

  const ProductActionButtons({
    super.key,
    required this.onAddToCart,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAddToCart,
            child: const Text("Add to Cart"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onContact,
            child: const Text("Contact Vendor"),
          ),
        ),
      ],
    );
  }
}
