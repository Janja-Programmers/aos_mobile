import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/legacy.dart';

final shortSessionControllerProvider =
    StateNotifierProvider<ShortSessionController, ShortsSessionState>(
      (ref) => ShortSessionController(),
    );

/// ─────────────────────────────────────────────
/// SESSION CONTROLLER (INTENT ONLY LAYER)
/// ─────────────────────────────────────────────
///
/// RULE:
/// ✔ This layer only describes "what changed"
/// ✔ It does NOT trigger playback
/// ✔ It does NOT interact with cache
/// ✔ It does NOT know video controllers
///
class ShortSessionController extends StateNotifier<ShortsSessionState> {
  ShortSessionController() : super(ShortsSessionState.initial());

  /// ─────────────────────────────────────────────
  /// ACTIVATE INDEX (INTENT UPDATE)
  /// ─────────────────────────────────────────────
  void activate(
    int index, {
    ScrollDirection direction = ScrollDirection.forward,
  }) {
    state = state.copyWith(
      activeIndex: index,
      status: SessionStatus.active,
      isUserInteracting: false,
      scrollDirection: direction,
    );
  }

  /// ─────────────────────────────────────────────
  /// TRANSITION START (USER IS SCROLLING)
  /// ─────────────────────────────────────────────
  void startTransition(
    int newIndex, {
    ScrollDirection direction = ScrollDirection.forward,
  }) {
    state = state.copyWith(
      activeIndex: newIndex,
      status: SessionStatus.transitioning,
      isUserInteracting: true,
      scrollDirection: direction,
    );
  }

  /// ─────────────────────────────────────────────
  /// TRANSITION COMPLETE
  /// ─────────────────────────────────────────────
  void completeTransition(int index) {
    state = state.copyWith(
      activeIndex: index,
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }

  /// ─────────────────────────────────────────────
  /// PAUSE SESSION (APP BACKGROUND)
  /// ─────────────────────────────────────────────
  void pause() {
    state = state.copyWith(
      status: SessionStatus.paused,
      isUserInteracting: false,
    );
  }

  /// ─────────────────────────────────────────────
  /// RESUME SESSION (APP FOREGROUND)
  /// ─────────────────────────────────────────────
  void resume() {
    state = state.copyWith(
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }

  /// ─────────────────────────────────────────────
  /// RESET SESSION STATE
  /// ─────────────────────────────────────────────
  void reset() {
    state = ShortsSessionState.initial();
  }

  /// ─────────────────────────────────────────────
  /// DEACTIVATE SESSION (EXIT FEED)
  /// ─────────────────────────────────────────────
  void deactivate() {
    state = state.copyWith(
      status: SessionStatus.inactive,
      activeIndex: -1,
      scrollDirection: ScrollDirection.idle,
      isUserInteracting: false,
    );
  }
}
