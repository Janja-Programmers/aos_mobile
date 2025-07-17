import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
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
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          _loading
              ? null
              : () async {
                if (_added) {
                  context.push('/cart');
                  return;
                }

                setState(() => _loading = true);

                final cart = context.read<CartProvider>();
                final success = await cart.add(widget.item);

                setState(() => _loading = false);

                if (success) {
                  setState(() => _added = true);
                  topSnackBar(
                    context,
                    '${widget.item.name} added to cart',
                    type: TopSnackType.success,
                  );
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: _added ? Colors.grey.shade400 : Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon:
          _loading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Icon(
                Icons.shopping_bag_outlined,
                color: _added ? Colors.black : Colors.grey,
              ),
      label: Text(
        _added ? 'Go to Cart' : 'Add to Cart',
        style: TextStyle(
          color: _added ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
