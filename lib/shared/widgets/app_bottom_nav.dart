import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 4:
            context.go(auth.isLoggedIn ? AppRoutes.account : AppRoutes.login);
            break;
          default:
            context.go(AppRoutes.home);
        }
      },
      items: [
        _navItem(Icons.home_outlined, 'Home', currentIndex == 0),
        _navItem(Icons.grid_view_outlined, 'Categories', currentIndex == 1),
        _navItem(Icons.sell_outlined, 'Selling', currentIndex == 2),
        _navItem(Icons.chat_bubble_outline, 'Messages', currentIndex == 3),
        _navItem(Icons.person_outline, 'Account', currentIndex == 4),
      ],
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool active) {
    return BottomNavigationBarItem(
      label: label,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Container(
              width: 20,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Icon(icon),
        ],
      ),
    );
  }
}
