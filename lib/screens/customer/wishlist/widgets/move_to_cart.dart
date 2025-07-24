import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';
import '/features/wishlist/provider.dart';

class MoveToCartButton extends StatefulWidget {
  final CartItem item;
  final String wishlistItemId;

  const MoveToCartButton({
    super.key,
    required this.item,
    required this.wishlistItemId,
  });

  @override
  State<MoveToCartButton> createState() => _MoveToCartButtonState();
}

class _MoveToCartButtonState extends State<MoveToCartButton> {
  bool _moved = false;
  bool _loading = false;

  Future<void> _moveToCart() async {
    setState(() => _loading = true);

    final cart = context.read<CartProvider>();
    final wishlist = context.read<WishlistProvider>();

    final added = await cart.add(widget.item);
    final removed = await wishlist.remove(widget.wishlistItemId);

    if (added && removed) {
      setState(() => _moved = true);
      topSnackBar(
        context,
        '${widget.item.name} moved to cart',
        type: TopSnackType.success,
      );
    } else {
      topSnackBar(
        context,
        'Failed to move ${widget.item.name} to cart',
        type: TopSnackType.error,
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          _loading
              ? null
              : () {
                if (_moved) {
                  context.push('/cart');
                } else {
                  _moveToCart();
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: _moved ? Colors.grey.shade400 : Colors.black,
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
                Icons.shopping_cart_outlined,
                color: _moved ? Colors.black : Colors.grey,
              ),
      label: Text(
        _moved ? 'Go to Cart' : 'Move to Cart',
        style: TextStyle(
          color: _moved ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
