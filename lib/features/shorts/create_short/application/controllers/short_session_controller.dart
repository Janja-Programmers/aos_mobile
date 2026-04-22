import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/state/short_session_state.dart';

/// ─────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────

final shortSessionControllerProvider =
    StateNotifierProvider<ShortSessionController, ShortsSessionState>(
      (ref) => ShortSessionController(),
    );

/// ─────────────────────────────────────────────
/// SESSION CONTROLLER (PLAYBACK STATE MACHINE)
/// ─────────────────────────────────────────────

class ShortSessionController extends StateNotifier<ShortsSessionState> {
  ShortSessionController() : super(ShortsSessionState.initial());

  // ─────────────────────────────────────────────
  // ACTIVATE SESSION
  // ─────────────────────────────────────────────

  void activate(int index) {
    state = state.copyWith(
      activeIndex: index,
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }

  // ─────────────────────────────────────────────
  // PAUSE SESSION (APP BACKGROUND / USER ACTION)
  // ─────────────────────────────────────────────

  void pause() {
    state = state.copyWith(
      status: SessionStatus.paused,
      isUserInteracting: false,
    );
  }

  // ─────────────────────────────────────────────
  // RESUME SESSION
  // ─────────────────────────────────────────────

  void resume() {
    state = state.copyWith(
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }

  // ─────────────────────────────────────────────
  // TRANSITION (PAGE SWIPE START)
  // ─────────────────────────────────────────────

  void startTransition(int newIndex) {
    state = state.copyWith(
      status: SessionStatus.transitioning,
      activeIndex: newIndex,
      isUserInteracting: true,
    );
  }

  // ─────────────────────────────────────────────
  // COMPLETE TRANSITION (PAGE SETTLED)
  // ─────────────────────────────────────────────

  void completeTransition(int index) {
    state = state.copyWith(
      activeIndex: index,
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }

  // ─────────────────────────────────────────────
  // RESET SESSION (FEED RESET / EXIT)
  // ─────────────────────────────────────────────

  void reset() {
    state = ShortsSessionState.initial();
  }
}
