import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/features/auth/presentation/auth_provider.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import 'cart_button.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomePressed;
  final List<Widget>? actions;

  const TopAppBar({super.key, this.onHomePressed, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/logo.png'),
            radius: 22,
            backgroundColor: AppColors.transparent,
          ),
        ),
      ),

      title: const Text('Own A Shop', style: TextStyle(color: AppColors.black)),
      actions:
          actions ??
          [
            const CartIconButton(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.person, color: AppColors.black),
              onSelected: (value) async {
                if (value == 'logout') {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  context.go('/login');
                } else if (value == 'orders') {
                  context.go('/');
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: 'orders', child: Text('My Orders')),
                    PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SubAppBar extends StatelessWidget {
  final String title;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

Future<void> showProfileMenu(BuildContext context, Offset offset) async {
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
    items: const [
      PopupMenuItem(value: 'orders', child: Text('My Orders')),
      PopupMenuItem(value: 'logout', child: Text('Logout')),
    ],
  );

  if (selected == 'logout') {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    context.go('/login');
  } else if (selected == 'orders') {
    context.go('/orders');
  }
}
