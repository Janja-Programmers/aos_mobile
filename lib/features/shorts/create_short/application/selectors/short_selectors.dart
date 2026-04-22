import 'package:africaonlinestores/features/shorts/create_short/application/state/short_session_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/shorts_feed_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/short_interaction_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';

/// ─────────────────────────────────────────────
/// SELECTORS (READ-ONLY DERIVED STATE)
/// ─────────────────────────────────────────────
/// Pure derivations → NO side effects
class ShortsSelectors {
  const ShortsSelectors();

  // ─────────────────────────────
  // CORE FEED
  // ─────────────────────────────

  Short? activeShort(ShortsFeedState state) {
    if (state.shorts.isEmpty) return null;
    if (state.activeIndex < 0 || state.activeIndex >= state.shorts.length) {
      return null;
    }
    return state.shorts[state.activeIndex];
  }

  bool isFeedEmpty(ShortsFeedState state) => state.shorts.isEmpty;

  bool hasNextPage(ShortsFeedState state) => state.nextCursor != null;

  // ─────────────────────────────
  // SESSION
  // ─────────────────────────────

  int activeIndex(ShortsSessionState session) => session.activeIndex;

  bool isSessionActive(ShortsSessionState session) => session.isActive;

  bool isUserInteracting(ShortsSessionState session) =>
      session.isUserInteracting;

  // ─────────────────────────────
  // INTERACTIONS
  // ─────────────────────────────

  bool isLiked(ShortInteractionState interaction, String shortId) {
    return interaction.likedShortIds.contains(shortId);
  }

  bool isLikePending(ShortInteractionState interaction, String shortId) {
    return interaction.pendingLikeActions.contains(shortId);
  }

  bool isMuted(ShortInteractionState interaction) => interaction.isMuted;

  // ─────────────────────────────
  // COMPOSITE UI DERIVATIONS
  // ─────────────────────────────

  bool shouldPlayVideo({
    required ShortsSessionState session,
    required ShortInteractionState interaction,
  }) {
    return session.isActive &&
        !session.isUserInteracting &&
        !interaction.isMuted;
  }

  bool isCurrentShortLiked({
    required ShortsFeedState feed,
    required ShortInteractionState interaction,
  }) {
    final short = activeShort(feed);
    if (short == null) return false;
    return interaction.likedShortIds.contains(short.id.value);
  }
}
