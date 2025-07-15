import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/provider.dart';

import '/shared/widgets/app_bars.dart';

import 'controllers/place_order.dart';

import 'widgets/cart_items_card.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/shipping_card.dart';

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

          final controller = PlaceOrderController(context);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CartItemsCard(items: items),
              const SizedBox(height: 16),
              ShippingAddressCard(controller: controller),
              const SizedBox(height: 16),
              PaymentSummaryCard(total: total, controller: controller),
            ],
          );
        },
      ),
    );
  }
}
