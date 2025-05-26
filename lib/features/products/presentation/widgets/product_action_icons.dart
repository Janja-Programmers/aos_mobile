import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../domain/product.dart';
import 'cart_icon_with_badge.dart';

class ProductActionIcons extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavToggle;
  final VoidCallback? onCartToggle;
  final VoidCallback onCallTap;

  const ProductActionIcons({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavToggle,
    required this.onCartToggle,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = !product.inStock;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: AppColors.primary,
          ),
          onPressed: onFavToggle,
          tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
        ),
        CartIconWithBadge(
          productId: product.id,
          onPressed: isOutOfStock ? null : onCartToggle,
        ),
        IconButton(
          icon: const Icon(Icons.call),
          color: AppColors.primary,
          onPressed: onCallTap,
          tooltip: 'Contact supplier',
        ),
      ],
    );
  }
}
