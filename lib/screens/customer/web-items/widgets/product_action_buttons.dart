import 'package:flutter/material.dart';

class ProductActionButtons extends StatelessWidget {
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback? onContact;

  const ProductActionButtons({
    super.key,
    required this.isInCart,
    required this.onAddToCart,
    required this.onViewCart,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
            ),
            label: Text(isInCart ? 'View in Cart' : 'Add to Cart'),
            onPressed: isInCart ? onViewCart : onAddToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (onContact != null) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text('Contact Vendor'),
            onPressed: onContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
