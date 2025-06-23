import 'package:flutter/material.dart';

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
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/logo.png'),
          radius: 22,
          backgroundColor: AppColors.transparent,
        ),
      ),

      title: const Text('Own A Shop', style: TextStyle(color: AppColors.black)),
      actions:
          actions ??
          [
            const CartIconButton(),
            IconButton(
              icon: const Icon(Icons.person, color: AppColors.black),
              onPressed: () {
                // Handle settings
              },
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
