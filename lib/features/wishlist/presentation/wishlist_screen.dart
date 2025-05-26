import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'wishlist_provider.dart';
import 'wishlist_item_card.dart';

// Cart Feature
import '../../cart/presentation/cart_provider.dart';
import '../../cart/domain/cart_item.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<WishlistProvider>(context, listen: false).loadWishlist(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cart') context.push('/cart');
              if (value == 'products') context.push('/products');
              // Add more navigation options as needed
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'cart', child: Text('Cart')),
                  const PopupMenuItem(
                    value: 'products',
                    child: Text('Products'),
                  ),
                  // Add more items as needed
                ],
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.items.isEmpty
              ? const Center(child: Text('🛍️ Your wishlist is empty'))
              : ListView.builder(
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  return WishlistItemCard(
                    item: item,
                    onRemove: () => provider.remove(item.id),

                    onAddToCart: () async {
                      final cartItem = CartItem(
                        id: item.id,
                        title: item.title,
                        imageUrl: item.imageUrl,
                        price: item.price,
                        quantity: 1,
                      );

                      await cart.add(cartItem);
                      await provider.remove(item.id);

                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🛒 Added to Cart and removed from Wishlist',
                              ),
                            ),
                          );
                      }
                    },
                  );
                },
              ),
    );
  }
}
