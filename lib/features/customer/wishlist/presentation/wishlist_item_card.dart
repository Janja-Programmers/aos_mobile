import 'package:flutter/material.dart';
import '../domain/wishlist_item.dart';

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(item.imageUrl, width: 60, fit: BoxFit.cover),
        title: Text(item.title),
        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: onAddToCart,
                tooltip: 'Add to Cart',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onRemove,
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
