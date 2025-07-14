import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';
import '/features/cart/domain/cart.dart';
import '/features/website/domain/webitem.dart';
import 'image_or_placeholder.dart';
import '../helper/add_to_cart_button.dart';

class ProductCard extends StatelessWidget {
  final WebsiteItem item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveImageUrl(item.imageUrl);

    return GestureDetector(
      onTap: () => context.push('/product/${item.name}'),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Card(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'product-${item.name}',
                child: ImageOrPlaceholder(
                  imageUrl: imageUrl,
                  fallbackText: item.name,
                ),
              ),
              Expanded(
                child: Padding(
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
                      item.inStock
                          ? SizedBox(
                            width: double.infinity,
                            child: AddToCartButton(
                              item: CartItem(
                                code: item.itemCode,
                                name: item.name,
                                price: item.price.toDouble(),
                                quantity: 1,
                                image: item.imageUrl,
                              ),
                            ),
                          )
                          : const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Color.fromARGB(255, 220, 71, 61),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
