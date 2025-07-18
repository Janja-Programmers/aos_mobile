import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/core/utils/logger.dart';
import 'package:provider/provider.dart';

import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';
import '/features/website/domain/webitem.dart';

import '../helper/add_to_cart_button.dart';
import '../helper/contact_vendor.dart';
import '../utils/vendor_card.dart';

class ProductActionBar extends StatelessWidget {
  final WebsiteItem product;

  const ProductActionBar({super.key, required this.product});

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

    appLogger.i(
      'ProductActionBar: Product ${product.id} of code ${product.itemCode} is in cart: $isInCart',
    );

    return Row(
      children: [
        Expanded(
          child:
              product.inStock
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
                  : const Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
