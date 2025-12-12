import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';
import '/features/website/domain/webitem.dart';

import '../helper/add_to_cart_button.dart';
import '../helper/contact_vendor.dart';
import '../utils/vendor_card.dart';

class ProductActionBar extends StatelessWidget {
  final WebsiteItem product;
  final bool inStock;

  const ProductActionBar({
    super.key,
    required this.product,
    required this.inStock,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.containsProduct(product.name);

    final cartItem = CartItem(
      code: product.itemCode,
      name: product.name,
      price: product.price,
      quantity: 1,
      image: product.imageUrl,
    );

    return Row(
      children: [
        Expanded(
          child:
              inStock
                  ? isInCart
                      ? ElevatedButton.icon(
                        onPressed: () => context.push('/cart'),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('View in Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                      : AddToCartButton(item: cartItem)
                  : const SizedBox.shrink(),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ContactVendorButton(
            onPressed: () => contactVendor(context, product),
          ),
        ),
      ],
    );
  }
}
