import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'cart_item_card.dart';
import 'cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CartProvider>(context, listen: false).loadCart(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'wishlist') context.push('/wishlist');
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
                  const PopupMenuItem(
                    value: 'wishlist',
                    child: Text('Wishlist'),
                  ),
                  // Add more items as needed
                ],
          ),
        ],
      ),
      body:
          cart.isLoading
              ? const Center(child: CircularProgressIndicator())
              : cart.items.isEmpty
              ? const Center(child: Text('🛒 Your cart is empty'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return CartItemCard(
                          item: item,
                          onAdd:
                              () => cart.updateQuantity(
                                item.id,
                                item.quantity + 1,
                              ),
                          onRemove:
                              () => cart.updateQuantity(
                                item.id,
                                item.quantity - 1,
                              ),
                          onDelete: () => cart.remove(item.id),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('\$${cart.totalPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Place Order'),
                          onPressed: () {
                            cart.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Order placed successfully!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
