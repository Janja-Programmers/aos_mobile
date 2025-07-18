import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';

import 'cart_button.dart';
import 'user_menu_button.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomePressed;
  final List<Widget>? actions;

  const TopAppBar({super.key, this.onHomePressed, this.actions});

  @override
  Widget build(BuildContext context) {
    final userType = context.read<AuthProvider>().user?.userType;
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

      title: Text('Own A Shop', style: const TextStyle(color: AppColors.black)),
      actions: [
        if (userType == 'Buyer') const CartIconButton(),
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
    context.go('/past-orders');
  }
}
