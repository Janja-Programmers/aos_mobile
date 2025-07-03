import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../address/shipping_address_form.dart';
import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';

import '/features/cart/provider.dart';
import '/features/auth/presentation/auth_provider.dart';

import '/shared/widgets/app_bars.dart';

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
                          final resolvedimage = resolveImageUrl(item.image);
                          return Card(
                            color: AppColors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey.shade200,
                                        child: ClipOval(
                                          child: Image.network(
                                            resolvedimage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (ctx, _, __) => const Icon(
                                                  Icons.broken_image,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      /// 🔥 FIX HERE
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      /// Quantity controls
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                provider.updateQuantity(
                                                  item.code,
                                                  item.quantity - 1,
                                                );
                                              }
                                            },
                                          ),
                                          Text('${item.quantity}'),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed: () {
                                              provider.updateQuantity(
                                                item.code,
                                                item.quantity + 1,
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                      /// Remove button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed:
                                            () => provider.remove(item.code),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Subtotal: KES ${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
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
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final cart = context.read<CartProvider>();
                                final user = context.read<AuthProvider>();

                                await cart.submitOrderWithExistingOrRedirect(
                                  customer: user.user!.username,
                                  openShippingForm: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder:
                                          (context) =>
                                              const ShippingAddressForm(),
                                    );
                                  },
                                  onSuccess: (addressUsed) {
                                    Future.delayed(Duration.zero, () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                'Order Successful',
                                              ),
                                              content: const Text(
                                                'Would you like to view your orders or continue shopping?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          context.go('/orders'),
                                                  child: const Text(
                                                    'View Orders',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => context.go('/'),
                                                  child: const Text(
                                                    'Continue Shopping',
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    });
                                  },
                                );
                              },

                              //   final success = await cart.submitOrder(
                              //     user.user!.username,
                              //     DateTime.now()
                              //         .toIso8601String()
                              //         .split('T')
                              //         .first,
                              //   );

                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(
                              //       content: Text(
                              //         success
                              //             ? 'Order placed successfully!'
                              //             : cart.error ??
                              //                 'Something went wrong',
                              //       ),
                              //     ),
                              //   );
                              // },
                              icon: const Icon(Icons.shopping_bag),
                              label: const Text('Place Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
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
