import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    appLogger.i('Initializing Live realtime coordinator');
    ref.read(liveRealtimeCoordinatorProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(liveManagerProvider.select((s) => s.hasLiveUi), (
      previous,
      next,
    ) {
      if (previous == next) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleNavigation(shouldShowLive: next);
      });
    });

    return widget.child;
  }

  void _handleNavigation({required bool shouldShowLive}) {
    if (_isNavigating) return;

    final router = ref.read(appRouterProvider);
    final currentLocation = router.state.matchedLocation;

    final isOnLiveScreen = currentLocation.contains(AppRoutes.liveRoom);

    // 👉 ENTER LIVE
    if (shouldShowLive && !isOnLiveScreen) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nLiveRoom);

      _isNavigating = false;

      return;
    }

    // 👉 EXIT LIVE
    if (!shouldShowLive && isOnLiveScreen) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nHome);

      _isNavigating = false;
    }
  }
}
