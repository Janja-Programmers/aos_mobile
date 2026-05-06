import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

class CallNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallNavigationListener({super.key, required this.child});

  @override
  ConsumerState<CallNavigationListener> createState() =>
      _CallNavigationListenerState();
}

class _CallNavigationListenerState
    extends ConsumerState<CallNavigationListener> {
  bool _isNavigating = false;

  late final ProviderSubscription<CallState> _sub;

  @override
  void initState() {
    super.initState();

    _sub = ref.listenManual<CallState>(callManagerProvider, (previous, next) {
      _onStateChanged(
        previousPhase: previous?.uiPhase,
        nextPhase: next.uiPhase,
      );
    });
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onStateChanged({
    required UiCallPhase? previousPhase,
    required UiCallPhase nextPhase,
  }) {
    if (previousPhase == nextPhase) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _handleNavigation(previousPhase: previousPhase, nextPhase: nextPhase);
    });
  }

  void _handleNavigation({
    required UiCallPhase? previousPhase,
    required UiCallPhase nextPhase,
  }) {
    final router = ref.read(appRouterProvider);

    final wasAosCallSessionPhase =
        previousPhase != null && _shouldBeOnAosCallSession(previousPhase);

    final shouldBeOnAosCallSession = _shouldBeOnAosCallSession(nextPhase);

    final shouldExitCallSession =
        wasAosCallSessionPhase && !shouldBeOnAosCallSession;

    /// EXIT MUST ALWAYS WIN.

    if (shouldExitCallSession) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});

      _releaseLock();
      return;
    }

    if (_isNavigating) return;

    final shouldEnterCallSession =
        !wasAosCallSessionPhase && shouldBeOnAosCallSession;

    if (shouldEnterCallSession) {
      _isNavigating = true;

      router.pushNamed(AppRoutes.nCallSession);

      _releaseLock();
    }
  }

  bool _shouldBeOnAosCallSession(UiCallPhase phase) {
    switch (phase) {
      /// Incoming ringing is owned by native CallKit.
      case UiCallPhase.incomingRinging:
        return false;

      /// Outgoing calls still use AOS UI.
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return true;

      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
        return false;
    }
  }

  void _releaseLock() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _isNavigating = false;
    });
  }
}
