import 'package:flutter/material.dart';

class AppNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String routeName;
  final bool requiresAuth;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.routeName,
    this.requiresAuth = false,
  });
}
