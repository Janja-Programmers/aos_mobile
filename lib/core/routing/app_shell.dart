import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/components/app_bottom_nav.dart';

/// ----------------------------------------------------------------------------
/// APP SHELL
/// ----------------------------------------------------------------------------

class AppShell extends StatelessWidget {
  final Widget child;

  final String location;

  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateIndex(location);

    // final hideBottomNav = false;

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/seller')) return 2;
    if (location.startsWith('/chats')) return 3;
    if (location.startsWith('/account')) return 4;

    return 0;
  }
}
