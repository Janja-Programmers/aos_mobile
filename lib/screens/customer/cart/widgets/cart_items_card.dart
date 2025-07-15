import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/cart/domain/cart.dart';

import 'cart_item_card.dart';

class CartItemsCard extends StatelessWidget {
  final List<CartItem> items;

  const CartItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  CartItemCard(item: item),
                  if (!isLast) const Divider(height: 20),
                ],
              );
            }).toList(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View Orders'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
