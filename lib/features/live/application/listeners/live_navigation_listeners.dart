import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';

class LiveNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const LiveNavigationListener({super.key, required this.child});

  @override
  ConsumerState<LiveNavigationListener> createState() =>
      _LiveNavigationListenerState();
}

class _LiveNavigationListenerState
    extends ConsumerState<LiveNavigationListener> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(socketLiveListenerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation(state.hasLiveUi);
    });

    return widget.child;
  }

  void _handleNavigation(bool shouldShowLive) {
    if (_isNavigating) return;

    final router = ref.read(appRouterProvider);
    final currentLocation = router.state.matchedLocation;

    final isOnLiveScreen = currentLocation.contains(AppRoutes.liveRoom);

    // 👉 ENTER LIVE
    if (shouldShowLive && !isOnLiveScreen) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nLiveRoom);

      Future.microtask(() => _isNavigating = false);
      return;
    }

    // 👉 EXIT LIVE
    if (!shouldShowLive && isOnLiveScreen) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nHome);

      Future.microtask(() => _isNavigating = false);
    }
  }
}
