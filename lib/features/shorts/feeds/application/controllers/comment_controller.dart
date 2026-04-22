import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/comment_state.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

class CommentsController extends StateNotifier<CommentsState> {
  final ShortsCommentsApi api;

  CommentsController(this.api) : super(CommentsState.initial());

  // ───────────── Initial COMMENT ─────────────

  Future<void> init(String shortId) async {
    if (state.comments.isNotEmpty) return;

    appLogger.i('🚀 INIT COMMENTS');

    await fetchComments(shortId);
  }

  // ───────────── ADD COMMENT ─────────────

  Future<void> addComment({
    required String shortId,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final optimistic = ShortComment(
      id: CommentId(tempId),
      shortId: ShortId(shortId),
      userId: "me",
      comment: comment,
      parentId: null,
      rootId: null,
      replyCount: 0,
      isDeleted: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    appLogger.i('💬 ADD COMMENT (optimistic)');

    // ✅ 1. Instant UI update
    _insertComment(optimistic);

    final res = await api.addComment(shortId: shortId, comment: comment);

    await res.fold(
      (e) {
        appLogger.e('❌ ADD COMMENT FAILED', error: e);

        // ❌ rollback optimistic comment
        _removeComment(tempId);
      },
      (_) async {
        appLogger.i('✅ COMMENT CONFIRMED');

        // 🔥 ALWAYS refetch (backend returns only id)
        await fetchComments(shortId);
      },
    );
  }

  // ───────────── FETCH COMMENTS ─────────────

  Future<void> fetchComments(String shortId) async {
    if (state.isLoading) return;

    appLogger.i('📥 FETCH COMMENTS');

    state = state.copyWith(isLoading: true);

    final res = await api.listComments(shortId: shortId);

    res.fold(
      (e) {
        appLogger.e('❌ FETCH COMMENTS FAILED', error: e);

        state = state.copyWith(isLoading: false);
      },
      (items) {
        appLogger.i('✅ COMMENTS LOADED | count=${items.length}');

        state = state.copyWith(comments: items, isLoading: false);
      },
    );
  }

  // ───────────── HELPERS ─────────────

  void _insertComment(ShortComment comment) {
    state = state.copyWith(comments: [comment, ...state.comments]);
  }

  void _removeComment(String tempId) {
    state = state.copyWith(
      comments: state.comments.where((c) => c.id.value != tempId).toList(),
    );
  }
}
