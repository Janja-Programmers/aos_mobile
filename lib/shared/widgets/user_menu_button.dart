import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/screens/auth/auth_provider.dart';
import '../utils/user_menu.dart';

class UserMenuButton extends StatelessWidget {
  final String userType;
  const UserMenuButton({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final loggedIn = authProvider.isLoggedIn;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.person, color: AppColors.black),
      onSelected: (value) async {
        await handleUserMenuSelection(context, value);
      },
      itemBuilder:
          (_) => buildUserMenuItems(loggedIn: loggedIn, userType: userType),
    );
  }
}
