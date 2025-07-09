import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/provider.dart';

import '/shared/widgets/app_bars.dart';

import 'controllers/place_order.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_footer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please login to view your cart.'),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: TopAppBar(),
      backgroundColor: AppColors.background,
      body: Consumer<CartProvider>(
        builder: (context, provider, _) {
          final items = provider.items;
          final total = provider.grandTotal;

          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white70,
                child: const Text(
                  'Shopping Cart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder:
                      (context, index) => CartItemCard(item: items[index]),
                ),
              ),
              const Divider(height: 1),
              CartFooter(
                total: total,
                onPlaceOrder: () async {
                  final controller = PlaceOrderController(context);
                  await controller.placeOrder();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
