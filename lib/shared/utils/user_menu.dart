import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/di/service_locator.dart';

import '../../screens/auth/auth_provider.dart';

/// Builds user-specific popup menu items with styling and icons.
List<PopupMenuEntry<String>> buildUserMenuItems(String userType) {
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
        value: 'view_website',
        child: Row(
          children: const [
            Icon(Icons.language, color: Colors.black54),
            SizedBox(width: 10),
            Text('View Website', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),

    PopupMenuItem(
      value: 'settings',
      child: Row(
        children: const [
          Icon(Icons.settings, color: Colors.black54),
          SizedBox(width: 10),
          Text(
            'Settings',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
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
    case 'orders':
      context.go('/past-orders');
      break;
    case 'view_website':
      context.go('/');
      break;
    case 'settings':
      context.go('/settings');
      break;
    case 'logout':
      final authProvider = sl<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        context.go('/login');
      }
      break;
  }
}
