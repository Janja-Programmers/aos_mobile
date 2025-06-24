import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';

class AddToCartButton extends StatefulWidget {
  final CartItem item;

  const AddToCartButton({super.key, required this.item});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = _added;

    return ElevatedButton.icon(
      onPressed:
          isDisabled
              ? null
              : () async {
                final cart = context.read<CartProvider>();
                final success = await cart.add(widget.item);

                if (success) {
                  setState(() => _added = true);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${widget.item.name} added to cart'),
                      ),
                    );
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.card_travel),
      label: Text(isDisabled ? 'Added to cart' : 'Add to cart'),
    );
  }
}
