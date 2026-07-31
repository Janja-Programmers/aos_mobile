import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum AppVisibilityPhase { foreground, inactive, hidden, background, detached }

class AppLifecycleSnapshot {
  const AppLifecycleSnapshot({
    required this.phase,
    required this.sequence,
    required this.isInitial,
  });

  final AppVisibilityPhase phase;
  final int sequence;
  final bool isInitial;

  bool get isVisible {
    return phase == AppVisibilityPhase.foreground ||
        phase == AppVisibilityPhase.inactive;
  }

  bool get shouldProtectContent {
    return phase == AppVisibilityPhase.hidden ||
        phase == AppVisibilityPhase.background ||
        phase == AppVisibilityPhase.detached;
  }
}

class AppLifecycleController extends StateNotifier<AppLifecycleSnapshot> {
  AppLifecycleController({AppLifecycleState? initialState})
    : super(
        AppLifecycleSnapshot(
          phase: _normalize(initialState),
          sequence: 0,
          isInitial: true,
        ),
      );

  void handlePlatformState(AppLifecycleState platformState) {
    final AppVisibilityPhase nextPhase = _normalize(platformState);
    if (state.phase == nextPhase && !state.isInitial) return;

    state = AppLifecycleSnapshot(
      phase: nextPhase,
      sequence: state.sequence + 1,
      isInitial: false,
    );
  }

  static AppVisibilityPhase _normalize(AppLifecycleState? state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return AppVisibilityPhase.foreground;
      case AppLifecycleState.inactive:
        return AppVisibilityPhase.inactive;
      case AppLifecycleState.hidden:
        return AppVisibilityPhase.hidden;
      case AppLifecycleState.paused:
        return AppVisibilityPhase.background;
      case AppLifecycleState.detached:
      case null:
        return AppVisibilityPhase.detached;
    }
  }
}

final appLifecycleInitialStateProvider = Provider<AppLifecycleState?>((ref) {
  return WidgetsBinding.instance.lifecycleState;
});

final appLifecycleControllerProvider =
    StateNotifierProvider<AppLifecycleController, AppLifecycleSnapshot>((ref) {
      return AppLifecycleController(
        initialState: ref.watch(appLifecycleInitialStateProvider),
      );
    });

class RootLifecycleCoordinator extends ConsumerStatefulWidget {
  const RootLifecycleCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<RootLifecycleCoordinator> createState() {
    return _RootLifecycleCoordinatorState();
  }
}

class _RootLifecycleCoordinatorState
    extends ConsumerState<RootLifecycleCoordinator> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onStateChange: _handleStateChange);
  }

  void _handleStateChange(AppLifecycleState state) {
    ref
        .read(appLifecycleControllerProvider.notifier)
        .handlePlatformState(state);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
