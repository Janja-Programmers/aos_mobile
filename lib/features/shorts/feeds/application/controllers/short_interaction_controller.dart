import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/short_interaction_state.dart';

/// ─────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────

final shortInteractionControllerProvider =
    StateNotifierProvider<ShortInteractionController, ShortInteractionState>(
      (ref) => ShortInteractionController(),
    );

/// ─────────────────────────────────────────────
/// CONTROLLER (INTERACTION ONLY)
/// ─────────────────────────────────────────────

class ShortInteractionController extends StateNotifier<ShortInteractionState> {
  ShortInteractionController() : super(ShortInteractionState.initial());

  // ─────────────────────────────────────────────
  // LIKE TOGGLE (OPTIMISTIC UI READY)
  // ─────────────────────────────────────────────

  void toggleLike(String shortId) {
    final isLiked = state.likedShortIds.contains(shortId);

    final updatedLikes = Set<String>.from(state.likedShortIds);
    final updatedPending = Set<String>.from(state.pendingLikeActions);

    // mark as pending
    updatedPending.add(shortId);

    if (isLiked) {
      updatedLikes.remove(shortId);
    } else {
      updatedLikes.add(shortId);
    }

    state = state.copyWith(
      likedShortIds: updatedLikes,
      pendingLikeActions: updatedPending,
    );
  }

  // ─────────────────────────────────────────────
  // CONFIRM LIKE SUCCESS (FROM API EVENT)
  // ─────────────────────────────────────────────

  void confirmLike(String shortId) {
    final updatedPending = Set<String>.from(state.pendingLikeActions);
    updatedPending.remove(shortId);

    state = state.copyWith(pendingLikeActions: updatedPending);
  }

  // ─────────────────────────────────────────────
  // REVERT LIKE (FAILURE HANDLING)
  // ─────────────────────────────────────────────

  void revertLike(String shortId) {
    final updatedLikes = Set<String>.from(state.likedShortIds);
    final updatedPending = Set<String>.from(state.pendingLikeActions);

    updatedLikes.remove(shortId);
    updatedPending.remove(shortId);

    state = state.copyWith(
      likedShortIds: updatedLikes,
      pendingLikeActions: updatedPending,
    );
  }

  // ─────────────────────────────────────────────
  // MUTE / UNMUTE GLOBAL SESSION AUDIO
  // ─────────────────────────────────────────────

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void setMute(bool value) {
    state = state.copyWith(isMuted: value);
  }

  // ─────────────────────────────────────────────
  // RESET (ON LOGOUT / FEED RESET)
  // ─────────────────────────────────────────────

  void reset() {
    state = ShortInteractionState.initial();
  }
}
