import 'package:flutter/material.dart';

enum AppNavBehavior { replace, push }

class AppNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String routeName;
  final String destinationPath;
  final List<String> activePathPrefixes;
  final bool requiresAuth;
  final AppNavBehavior behavior;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.routeName,
    required this.destinationPath,
    this.activePathPrefixes = const [],
    this.requiresAuth = false,
    this.behavior = AppNavBehavior.replace,
  });

  bool matchesLocation(String location) {
    final path = Uri.tryParse(location)?.path ?? location.split('?').first;

    if (path == destinationPath) return true;

    return activePathPrefixes.any(
      (prefix) => path == prefix || path.startsWith('$prefix/'),
    );
  }

  bool isDestination(String location) {
    final path = Uri.tryParse(location)?.path ?? location.split('?').first;
    return path == destinationPath;
  }
}
