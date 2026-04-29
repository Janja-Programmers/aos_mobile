import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/live/comments/live_comments_state.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';

final liveCommentsControllerProvider =
    StateNotifierProvider<LiveCommentsController, LiveCommentsState>((ref) {
      final api = ref.watch(liveCommentsApiProvider);
      return LiveCommentsController(api);
    });

class LiveCommentsController extends StateNotifier<LiveCommentsState> {
  final LiveCommentsApi api;

  LiveCommentsController(this.api) : super(LiveCommentsState.initial());

  // ───────────── INIT COMMENTS ─────────────

  Future<void> init(String liveId) async {
    if (state.comments.isNotEmpty) return;

    appLogger.i('🚀 INIT LIVE COMMENTS');

    await fetchComments(liveId);
  }

  // ───────────── ADD COMMENT ─────────────

  Future<void> addComment({
    required String liveId,
    required String comment,
  }) async {
    final text = comment.trim();
    if (text.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final optimistic = LiveComment(
      id: tempId,
      liveId: liveId,
      userId: 'me',
      comment: text,
      parentId: null,
      rootId: null,
      replyCount: 0,
      isDeleted: false,
      createdAt: DateTime.now(),
    );

    appLogger.i('💬 ADD LIVE COMMENT optimistic');

    _insertComment(optimistic);

    final res = await api.addComment(liveId: liveId, comment: text);

    await res.fold(
      (e) async {
        appLogger.e('❌ ADD LIVE COMMENT FAILED', error: e);

        _removeComment(tempId);

        state = state.copyWith(errorMessage: e.message);
      },
      (_) async {
        appLogger.i('✅ LIVE COMMENT CONFIRMED');

        await fetchComments(liveId);
      },
    );
  }

  // ───────────── FETCH COMMENTS ─────────────

  Future<void> fetchComments(String liveId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await api.listComments(liveId: liveId);

      res.fold(
        (e) {
          state = state.copyWith(
            comments: [],
            isLoading: false,
            errorMessage: e.message,
          );
        },
        (items) {
          state = state.copyWith(
            comments: items,
            isLoading: false,
            clearError: true,
          );
        },
      );
    } catch (e, s) {
      appLogger.e('fetch live comments failed', error: e, stackTrace: s);

      state = state.copyWith(
        comments: [],
        isLoading: false,
        errorMessage: 'Failed to load live comments',
      );
    }
  }

  // ───────────── DELETE COMMENT ─────────────

  Future<void> deleteComment({required String commentId}) async {
    final previous = state.comments;

    state = state.copyWith(
      comments: state.comments.where((c) => c.id != commentId).toList(),
      clearError: true,
    );

    final res = await api.deleteComment(commentId: commentId);

    res.fold(
      (e) {
        appLogger.e('❌ DELETE LIVE COMMENT FAILED', error: e);

        state = state.copyWith(comments: previous, errorMessage: e.message);
      },
      (_) {
        appLogger.i('🗑️ LIVE COMMENT DELETED');
      },
    );
  }

  // ───────────── HELPERS ─────────────

  void _insertComment(LiveComment comment) {
    state = state.copyWith(
      comments: [comment, ...state.comments],
      clearError: true,
    );
  }

  void _removeComment(String tempId) {
    state = state.copyWith(
      comments: state.comments.where((c) => c.id != tempId).toList(),
    );
  }
}
