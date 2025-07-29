import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/wishlist/provider.dart';

class WishlistIconButton extends StatelessWidget {
  const WishlistIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<WishlistProvider>().items.length;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            count > 0 ? Icons.favorite : Icons.favorite_border,
            color: AppColors.black,
          ),
          onPressed: () {
            context.push('/wishlist');
          },
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
