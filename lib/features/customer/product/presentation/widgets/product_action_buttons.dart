import 'package:amani_mall/features/customer/product/presentation/widgets/supplier_contact_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Product feature;
import '../../../../shared/products/domain/product.dart';

// Cart feature;
import '../../../cart/presentation/cart_provider.dart';
import '../../../cart/domain/cart_item.dart';
import 'cart_icon_with_badge.dart';

// Wishlist feature;
import '../../../wishlist/domain/wishlist_item.dart';
import '../../../wishlist/presentation/wishlist_provider.dart';

class ProductActionButtons extends StatelessWidget {
  final Product product;
  final bool isAddToCartEnabled;

  const ProductActionButtons({
    super.key,
    required this.product,
    this.isAddToCartEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    final isFavorite = wishlist.isInWishlist(product.id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            final item = WishlistItem(
              id: product.id,
              title: product.title,
              imageUrl: product.imageUrl,
              price: product.price,
            );

            isFavorite ? wishlist.remove(product.id) : wishlist.add(item);
          },
        ),
        CartIconWithBadge(
          productId: product.id,
          onPressed:
              product.inStock
                  ? () {
                    final cartItem = CartItem(
                      id: product.id,
                      title: product.title,
                      imageUrl: product.imageUrl,
                      price: product.price,
                      quantity: 1,
                    );
                    final isNew = !cart.items.any((e) => e.id == product.id);
                    cart.add(cartItem);
                    if (isNew) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('🛒 Added to Cart')),
                        );
                    }
                  }
                  : null, // disables button if out of stock
        ),

        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // Optional: trigger call sheet if needed here
            showModalBottomSheet(
              context: context,
              builder: (_) => SupplierContactSheet(product: product),
            );
          },
        ),
      ],
    );
  }
}
