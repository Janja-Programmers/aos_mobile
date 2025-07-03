import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/cart/provider.dart';

import '/shared/widgets/app_bars.dart';
import 'controllers/place_order.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(),
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white70,
            child: const Text(
              'Shopping Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 🔥 Wrap Consumer in Expanded
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, provider, _) {
                final items = provider.items;
                final total = provider.grandTotal;

                if (items.isEmpty) {
                  return const Center(child: Text('Your cart is empty.'));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CartItemTile(item: item);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'KES ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: Consumer<CartProvider>(
                              builder: (context, provider, _) {
                                final isLoading = provider.isLoading;

                                return ElevatedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () async {
                                            final controller =
                                                PlaceOrderController(context);
                                            await controller.placeOrder();
                                          },
                                  icon:
                                      isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(Icons.shopping_bag),
                                  label: Text(
                                    isLoading
                                        ? 'Placing Order...'
                                        : 'Place Order',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
