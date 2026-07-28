import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/shared/components/app_bottom_nav.dart';
import 'package:flutter/material.dart';

/// ----------------------------------------------------------------------------
/// APP SHELL
/// ----------------------------------------------------------------------------

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppNavConfig.indexForLocation(context, location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }
}
