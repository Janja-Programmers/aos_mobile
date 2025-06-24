import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/features/cart/provider.dart';
import '/core/constants/colors.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.card_travel, color: AppColors.black),
              onPressed: () {
                context.go('/cart');
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cart.items.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
