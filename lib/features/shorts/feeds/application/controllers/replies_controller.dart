import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/replies_state.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

class RepliesController extends StateNotifier<RepliesState> {
  final ShortsCommentsApi api;
  final String rootCommentId;

  RepliesController(this.api, this.rootCommentId)
    : super(RepliesState.initial());

  // ───────────── INIT ─────────────

  Future<void> init(String rootCommentId) async {
    if (state.replies.isNotEmpty) return;

    await fetchReplies(rootCommentId);
  }

  // ───────────── FETCH ─────────────

  Future<void> fetchReplies(String rootCommentId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final res = await api.listReplies(rootCommentId: this.rootCommentId);

    res.fold(
      (e) {
        appLogger.e('❌ FETCH REPLIES FAILED', error: e);
        state = state.copyWith(isLoading: false);
      },
      (items) {
        appLogger.i('✅ REPLIES LOADED | count=${items.length}');

        state = state.copyWith(replies: items, isLoading: false);
      },
    );
  }

  // ───────────── ADD REPLY ─────────────

  Future<void> reply({
    required String rootCommentId,
    required String parentCommentId,
    required String shortId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final optimistic = ShortComment(
      id: CommentId(tempId),
      shortId: ShortId(shortId),
      userId: "me",
      comment: content,
      parentId: CommentId(parentCommentId),
      rootId: CommentId(rootCommentId),
      replyCount: 0,
      isDeleted: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    // 🔥 optimistic insert
    _insertReply(optimistic);

    final res = await api.replyComment(
      parentCommentId: parentCommentId,
      comment: content,
    );

    await res.fold(
      (e) {
        appLogger.e('❌ REPLY FAILED', error: e);
        _removeReply(tempId);
      },
      (_) async {
        appLogger.i('✅ REPLY CONFIRMED');

        // 🔥 refetch (backend only returns id)
        await fetchReplies(rootCommentId);
      },
    );
  }

  // ───────────── HELPERS ─────────────

  void _insertReply(ShortComment reply) {
    state = state.copyWith(replies: [...state.replies, reply]);
  }

  void _removeReply(String tempId) {
    state = state.copyWith(
      replies: state.replies.where((r) => r.id.value != tempId).toList(),
    );
  }
}
