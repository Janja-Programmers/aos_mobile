import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';

import '/features/wishlist/domain/wishlist_item.dart';
import '/screens/customer/web-items/widgets/image_or_placeholder.dart';

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final bool? inStock;
  final VoidCallback? onTap;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.inStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveImageUrl(item.imageUrl);

    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Hero(
                  tag: '/product/${item.id}',
                  child: ImageOrPlaceholder(
                    imageUrl: imageUrl,
                    fallbackText: item.title,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
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
                      formatCurrency(item.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    // const SizedBox(height: 8),

                    // // 👇 Conditional rendering of the MoveToCartButton
                    // if (inStock == null || inStock == true)
                    //   SizedBox(
                    //     width: double.infinity,
                    //     child: MoveToCartButton(
                    //       item: CartItem(
                    //         code: item.id,
                    //         name: item.title,
                    //         image: item.imageUrl,
                    //         price: item.price,
                    //         quantity: 1,
                    //       ),
                    //       wishlistItemId: item.id,
                    //     ),
                    //   )
                    // else
                    //   const Text(
                    //     'Out of Stock',
                    //     style: TextStyle(
                    //       color: Color.fromARGB(255, 220, 71, 61),
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onRemove,
              child: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
