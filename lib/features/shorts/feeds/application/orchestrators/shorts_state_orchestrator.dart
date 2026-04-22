import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';

/// ─────────────────────────────────────────────
/// SHORTS ORCHESTRATOR (STATE MACHINE CORE)
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → deterministic state transitions for feed + session
///
class ShortsStateOrchestrator {
  const ShortsStateOrchestrator();

  // ─────────────────────────────────────────────
  // FEED INITIALIZATION
  // ─────────────────────────────────────────────

  ShortsFeedState initializeFeed({
    required List<Short> items,
    required String? nextCursor,
  }) {
    if (items.isEmpty) {
      return ShortsFeedState.initial().copyWith(status: ShortsFeedStatus.empty);
    }

    return ShortsFeedState(
      status: ShortsFeedStatus.ready,
      shorts: _filterPlayable(items),
      nextCursor: nextCursor,
      errorMessage: null,
      activeIndex: 0,
    );
  }

  // ─────────────────────────────────────────────
  // PAGE CHANGE (SESSION TRANSITION)
  // ─────────────────────────────────────────────

  ShortsFeedState onPageChanged({
    required ShortsFeedState state,
    required int newIndex,
  }) {
    if (newIndex < 0 || newIndex >= state.shorts.length) {
      return state;
    }

    return state.copyWith(activeIndex: newIndex);
  }

  ShortsSessionState syncSession({
    required ShortsSessionState session,
    required int newIndex,
  }) {
    return session.copyWith(
      activeIndex: newIndex,
      status: SessionStatus.active,
      isUserInteracting: false,
    );
  }
  // ─────────────────────────────────────────────
  // PAGINATION APPEND
  // ─────────────────────────────────────────────

  ShortsFeedState appendFeed({
    required ShortsFeedState state,
    required List<Short> newItems,
    required String? nextCursor,
  }) {
    final merged = [...state.shorts, ..._filterPlayable(newItems)];

    return state.copyWith(
      shorts: merged,
      nextCursor: nextCursor,
      status: ShortsFeedStatus.ready,
    );
  }

  // ─────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────

  ShortsFeedState failFeed({
    required ShortsFeedState state,
    required String message,
  }) {
    return state.copyWith(
      status: ShortsFeedStatus.error,
      errorMessage: message,
    );
  }

  // ─────────────────────────────────────────────
  // DOMAIN-AWARE FILTERING
  // ─────────────────────────────────────────────

  List<Short> _filterPlayable(List<Short> items) {
    return items.where((s) {
      final status = s.status;
      return status == ShortStatus.ready ||
          status == ShortStatus.processing ||
          status == ShortStatus.uploaded;
    }).toList();
  }
}
