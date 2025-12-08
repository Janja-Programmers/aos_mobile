import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/screens/auth/auth_provider.dart';

List<PopupMenuEntry<String>> buildUserMenuItems({
  required bool loggedIn,
  required String userType,
}) {
  // Not logged in → show only Login/Register
  if (!loggedIn) {
    return [
      PopupMenuItem(
        value: 'login',
        child: Row(
          children: const [
            Icon(Icons.login, color: Colors.black54),
            SizedBox(width: 10),
            Text('Login', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'register',
        child: Row(
          children: const [
            Icon(Icons.app_registration, color: Colors.black54),
            SizedBox(width: 10),
            Text('Register', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    ];
  }

  // Logged in → show user-specific menu
  return [
    if (userType == 'Buyer')
      PopupMenuItem(
        value: 'orders',
        child: Row(
          children: const [
            Icon(Icons.shopping_bag, color: Colors.black54),
            SizedBox(width: 10),
            Text('My Orders', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    if (userType == 'Vendor')
      PopupMenuItem(
        value: 'browse_products',
        child: Row(
          children: const [
            Icon(Icons.language, color: Colors.black54),
            SizedBox(width: 10),
            Text('Browse Products', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),

    PopupMenuItem(
      value: 'logout',
      child: Row(
        children: const [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 10),
          Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14)),
        ],
      ),
    ),
  ];
}

/// Handles selection actions from the popup menu.
Future<void> handleUserMenuSelection(BuildContext context, String value) async {
  switch (value) {
    case 'login':
      context.push('/login');
      break;
    case 'register':
      context.push('/register');
      break;
    case 'orders':
      context.push('/past-orders');
      break;
    case 'browse_products':
      context.push('/');
      break;
    case 'logout':
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (context.mounted) {
        Future.microtask(() => context.go('/'));
      }
      break;
  }
}
