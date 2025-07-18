import 'package:flutter/material.dart';
import 'package:ownashop/core/constants/colors.dart';

import '../utils/user_menu.dart';

class UserMenuButton extends StatelessWidget {
  final String userType;
  const UserMenuButton({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person, color: AppColors.black),
      onSelected: (value) => handleUserMenuSelection(context, value),
      itemBuilder: (_) => buildUserMenuItems(userType),
    );
  }
}
