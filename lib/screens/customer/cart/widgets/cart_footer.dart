import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/provider.dart';

import '../../address/shipping_address_form.dart';

class CartFooter extends StatelessWidget {
  final double total;

  const CartFooter({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Place Order'),
              onPressed: () async {
                final cart = context.read<CartProvider>();
                final auth = context.read<AuthProvider>();

                final user = auth.user;
                if (user == null) {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Login Required'),
                          content: const Text(
                            'Please log in to place your order.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Login'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                  );
                  return;
                }

                await cart.submitOrderWithExistingOrRedirect(
                  customer: user.username,
                  openShippingForm: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => const ShippingAddressForm(),
                    );
                  },
                  onSuccess: (_) {
                    Future.delayed(Duration.zero, () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Order Successful'),
                              content: const Text(
                                'Would you like to view your orders or continue shopping?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.go('/orders'),
                                  child: const Text('View Orders'),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/'),
                                  child: const Text('Continue Shopping'),
                                ),
                              ],
                            ),
                      );
                    });
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
