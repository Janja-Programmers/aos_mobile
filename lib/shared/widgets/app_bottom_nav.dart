import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/features/cart/provider.dart';
import '/features/wishlist/provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().items.length;
    final wishlistCount = context.watch<WishlistProvider>().items.length;
    final current = GoRouterState.of(context).uri.toString();

    int index = switch (current) {
      '/' => 0,
      '/wishlist' => 1,
      '/cart' => 2,
      '/settings' => 3,
      _ => 0,
    };

    return NavigationBar(
      backgroundColor: AppColors.white,
      selectedIndex: index,
      elevation: 3,
      indicatorColor: AppColors.primary.withOpacity(.15),

      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/wishlist');
            break;
          case 2:
            context.go('/cart');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },

      destinations: [
        /// --- HOME ---
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Home',
        ),

        /// --- WISHLIST ---
        NavigationDestination(
          icon: Badge(
            isLabelVisible: wishlistCount > 0,
            label: Text('$wishlistCount'),
            child: const Icon(Icons.favorite_border),
          ),
          selectedIcon: Badge(
            isLabelVisible: wishlistCount > 0,
            label: Text('$wishlistCount'),
            child: const Icon(Icons.favorite),
          ),
          label: 'Wishlist',
        ),

        /// --- CART ---
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),

        /// --- ACCOUNT ---
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}
