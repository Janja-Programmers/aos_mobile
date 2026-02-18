import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/shared/components/app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final currentIndex = _calculateIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/seller')) return 2;
    if (location.startsWith('/messages')) return 3;
    if (location.startsWith('/account')) return 4;
    return 0;
  }
}
