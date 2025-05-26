import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/cart_provider.dart';

class CartIconWithBadge extends StatelessWidget {
  final String productId;
  final VoidCallback? onPressed;

  const CartIconWithBadge({
    super.key,
    required this.productId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        onPressed == null ? Colors.grey : Theme.of(context).iconTheme.color;

    final cartProvider = Provider.of<CartProvider>(context);
    final quantity =
        cartProvider.items
            .firstWhereOrNull((e) => e.id == productId)
            ?.quantity ??
        0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: iconColor),
          onPressed: onPressed,
          tooltip: onPressed != null ? 'Add to Cart' : 'Out of Stock',
        ),
        if (quantity > 0)
          Positioned(
            top: 4,
            right: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: child,
                  ),
              child: CircleAvatar(
                key: ValueKey(quantity),
                radius: 9,
                backgroundColor: AppColors.danger,
                child: Text(
                  '$quantity',
                  style: const TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
