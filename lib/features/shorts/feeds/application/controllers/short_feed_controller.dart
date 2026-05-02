// import 'package:africaonlinestores/core/utils/logger.dart';
// import 'package:flutter_riverpod/legacy.dart';

// import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_state.dart';
// import 'package:africaonlinestores/features/shorts/feeds/application/orchestrators/shorts_state_orchestrator.dart';
// import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
// import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
// import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

// /// ─────────────────────────────────────────────
// /// PROVIDER
// /// ─────────────────────────────────────────────

// final shortsFeedControllerProvider =
//     StateNotifierProvider<ShortsFeedController, ShortsFeedState>((ref) {
//       return ShortsFeedController(
//         ref.read(shortsRepositoryProvider),
//         const ShortsStateOrchestrator(),
//       );
//     });

// /// ─────────────────────────────────────────────
// /// CONTROLLER (INTENT LAYER ONLY)
// /// ─────────────────────────────────────────────

// class ShortsFeedController extends StateNotifier<ShortsFeedState> {
//   final ShortsRepository _repo;

//   ShortsFeedController(this._repo, this._orchestrator)
//     : super(ShortsFeedState.initial());

//   // ─────────────────────────────────────────────
//   // INITIAL LOAD
//   // ─────────────────────────────────────────────

//   Future<void> loadForYou() async {
//     appLogger.i("📥 LOAD START");

//     state = state.copyWith(status: ShortsFeedStatus.loading);

//     try {
//       final page = await _repo.fetchForYou();

//       state = _orchestrator.initializeFeed(
//         items: page.items,
//         nextCursor: page.nextCursor,
//       );

//       appLogger.i("✅ LOADED | shorts=${state.shorts.length}");
//     } catch (e) {
//       state = _orchestrator.failFeed(state: state, message: e.toString());
//     }
//   }

//   void initialize({required List<Short> items, required String? nextCursor}) {
//     state = _orchestrator.initializeFeed(items: items, nextCursor: nextCursor);
//     appLogger.i("📥 FETCH START | ShortsFeedController | initialize");
//   }

//   // ─────────────────────────────────────────────
//   // PAGE CHANGE (UI SCROLL EVENT)
//   // ─────────────────────────────────────────────

//   void onPageChanged(int index, ShortsSessionState session) {
//     state = _orchestrator.onPageChanged(state: state, newIndex: index);

//     // session sync is intentionally separate state machine
//   }

//   // ─────────────────────────────────────────────
//   // SESSION SYNC HOOK
//   // ─────────────────────────────────────────────

//   ShortsSessionState syncSession(ShortsSessionState session, int index) {
//     return _orchestrator.syncSession(session: session, newIndex: index);
//   }

//   // ─────────────────────────────────────────────
//   // PAGINATION
//   // ─────────────────────────────────────────────

//   void append({required List<Short> items, required String? nextCursor}) {
//     state = _orchestrator.appendFeed(
//       state: state,
//       newItems: items,
//       nextCursor: nextCursor,
//     );
//   }

//   // ─────────────────────────────────────────────
//   // ERROR HANDLING
//   // ─────────────────────────────────────────────

//   void fail(String message) {
//     state = _orchestrator.failFeed(state: state, message: message);
//   }

//   // ─────────────────────────────────────────────
//   // ACTIVE INDEX SETTER (SAFE ENTRY POINT)
//   // ─────────────────────────────────────────────

//   void setActiveIndex(int index) {
//     state = state.copyWith(activeIndex: index);
//   }
// }
