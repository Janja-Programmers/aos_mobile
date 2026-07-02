import 'package:africaonlinestores/features/shorts/feeds/application/state/short_interaction_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ─────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────

final shortInteractionControllerProvider =
    StateNotifierProvider<ShortInteractionController, ShortInteractionState>((
      ref,
    ) {
      final api = ref.read(shortsEngagementApiProvider);

      return ShortInteractionController(api);
    });

/// ─────────────────────────────────────────────
/// CONTROLLER (INTERACTION ONLY)
/// ─────────────────────────────────────────────

class ShortInteractionController extends StateNotifier<ShortInteractionState> {
  ShortInteractionController(this._api)
    : super(ShortInteractionState.initial());

  final ShortsEngagementApi _api;

  Future<void> toggleLike(String shortId) async {
    if (state.pendingLikeActions.contains(shortId)) return;

    final wasLiked = state.likedShortIds.contains(shortId);

    final updatedLikes = Set<String>.from(state.likedShortIds);
    final updatedPending = Set<String>.from(state.pendingLikeActions);

    updatedPending.add(shortId);

    if (wasLiked) {
      updatedLikes.remove(shortId);
    } else {
      updatedLikes.add(shortId);
    }

    state = state.copyWith(
      likedShortIds: updatedLikes,
      pendingLikeActions: updatedPending,
    );

    try {
      await _api.toggleLike(shortId: shortId);

      final pending = Set<String>.from(state.pendingLikeActions);
      pending.remove(shortId);

      state = state.copyWith(pendingLikeActions: pending);
    } catch (e) {
      final revertedLikes = Set<String>.from(state.likedShortIds);
      final pending = Set<String>.from(state.pendingLikeActions);

      if (wasLiked) {
        revertedLikes.add(shortId);
      } else {
        revertedLikes.remove(shortId);
      }

      pending.remove(shortId);

      state = state.copyWith(
        likedShortIds: revertedLikes,
        pendingLikeActions: pending,
      );
    }
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
