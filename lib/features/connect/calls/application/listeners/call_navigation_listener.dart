import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      _onStateChanged(previous: previous, next: next);
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
    required CallState? previous,
    required CallState next,
  }) {
    if (previous?.uiPhase == next.uiPhase &&
        previous?.backendStatus == next.backendStatus &&
        previous?.direction == next.direction) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _handleNavigation(previous: previous, next: next);
    });
  }

  void _handleNavigation({
    required CallState? previous,
    required CallState next,
  }) {
    final router = ref.read(appRouterProvider);

    final wasAosCallSessionPhase =
        previous != null && _shouldBeOnAosCallSession(previous);

    final shouldBeOnAosCallSession = _shouldBeOnAosCallSession(next);

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

  bool _shouldBeOnAosCallSession(CallState state) {
    if (state.isOutgoingNoAnswer) {
      return true;
    }

    switch (state.uiPhase) {
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
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _isNavigating = false;
    });
  }
}
