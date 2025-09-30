import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';
import '/core/utils/logger.dart';

import '/features/cart/domain/cart.dart';
import '/features/website/domain/webitem.dart';
import '/features/wishlist/domain/wishlist_item.dart';
import '/features/wishlist/provider.dart';

import '../helper/add_to_wishlist.dart';
import '../helper/add_to_cart_button.dart';

import 'image_or_placeholder.dart';

class ProductCard extends StatelessWidget {
  final WebsiteItem item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveImageUrl(item.imageUrl);
    final wishlistProv = context.watch<WishlistProvider>();
    final isWished = wishlistProv.isInWishlist(item.itemCode);

    return GestureDetector(
      onTap: () {
        appLogger.f('Tapped on product: ${item.name}');
        context.read<WishlistProvider>().loadWishlist();
        context.push('/product/${item.itemCode}');
        appLogger.f('Tapped on product: ${item.itemCode}');
      },
      child: Card(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'product-${item.name}',
                  child: ImageOrPlaceholder(
                    imageUrl: imageUrl,
                    fallbackText: item.name,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.itemGroup,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(item.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),

                      SizedBox(
                        width: double.infinity,
                        child:
                            item.inStock
                                ? AddToCartButton(
                                  item: CartItem(
                                    code: item.itemCode,
                                    name: item.name,
                                    price: item.price.toDouble(),
                                    quantity: 1,
                                    image: item.imageUrl,
                                  ),
                                )
                                : const Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 220, 71, 61),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  handleToggleWishlist(
                    context,
                    wishlistProv,
                    WishlistItem(
                      id: item.itemCode,
                      title: item.name,
                      imageUrl: item.imageUrl,
                      price: item.price.toDouble(),
                    ),
                  );
                },
                child: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
