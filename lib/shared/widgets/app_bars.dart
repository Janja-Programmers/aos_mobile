import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/screens/auth/auth_provider.dart';
import '/features/cart/provider.dart';
import '/features/wishlist/provider.dart';

import 'cart_button.dart';
import 'user_menu_button.dart';
import 'wishlist_icon_button.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomePressed;
  final List<Widget>? actions;

  const TopAppBar({super.key, this.onHomePressed, this.actions});

  @override
  Widget build(BuildContext context) {
    final userType = context.read<AuthProvider>().user?.userType;

    final cartCount = context.watch<CartProvider>().items.length;
    final wishlistCount = context.watch<WishlistProvider>().items.length;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/logo.png'),
            radius: 22,
            backgroundColor: AppColors.transparent,
          ),
        ),
      ),
      title: const Text('Africa Online Stores', style: TextStyle(color: AppColors.black)),
      actions: [
        if (userType == 'Buyer' && cartCount > 0) const CartIconButton(),
        if (userType == 'Buyer' && wishlistCount > 0)
          const WishlistIconButton(),
        ...?actions,
        UserMenuButton(userType: userType ?? 'Buyer'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SubAppBar extends StatelessWidget {
  final Widget title;
  final VoidCallback onMenuPressed;
  final VoidCallback? onSavePressed;
  final bool showSaveButton;
  final Widget? actionButton;

  const SubAppBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.onSavePressed,
    this.showSaveButton = true,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu),
              ),
              const SizedBox(width: 4),
              title,
            ],
          ),

          Row(
            children: [
              if (actionButton != null) actionButton!,
              if (showSaveButton && onSavePressed != null)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: onSavePressed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
