import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/replies_state.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
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

    state = state.copyWith(
      isLoading: true,
      clearNextCursor: true,
      hasMore: false,
    );

    final res = await api.listReplies(rootCommentId: this.rootCommentId);

    res.fold(
      (e) {
        appLogger.e('❌ FETCH REPLIES FAILED', error: e);
        state = state.copyWith(isLoading: false, hasMore: false);
      },
      (page) {
        appLogger.i('✅ REPLIES LOADED | count=${page.items.length}');

        state = state.copyWith(
          replies: List.unmodifiable(page.items),
          isLoading: false,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );
      },
    );
  }

  Future<void> loadMoreReplies() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final cursor = state.nextCursor?.trim();
    if (cursor == null || cursor.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    final res = await api.listReplies(
      rootCommentId: rootCommentId,
      cursor: cursor,
    );

    res.fold(
      (e) {
        state = state.copyWith(isLoadingMore: false);
      },
      (page) {
        state = state.copyWith(
          replies: List.unmodifiable([...state.replies, ...page.items]),
          isLoadingMore: false,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );
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
    final trimmed = content.trim();

    if (trimmed.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final optimistic = ShortComment(
      id: CommentId(tempId),
      shortId: ShortId(shortId),
      userId: 'me',
      displayName: 'You',
      avatar: null,
      comment: trimmed,
      parentId: parentCommentId,
      rootId: rootCommentId,
      replyCount: 0,
      likeCount: 0,
      isLiked: false,
      isOwner: true,
      canDelete: true,
      isDeleted: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _insertReply(optimistic);

    final res = await api.replyComment(
      parentCommentId: parentCommentId,
      comment: trimmed,
    );

    await res.fold(
      (e) {
        appLogger.e('❌ REPLY FAILED', error: e);

        _removeReply(tempId);
      },
      (_) async {
        appLogger.i('✅ REPLY CONFIRMED');

        await fetchReplies(rootCommentId);
      },
    );
  }

  // ───────────── TOGGLE REPLY LIKE ─────────────

  Future<void> toggleCommentLike(String commentId) async {
    if (state.pendingLikeIds.contains(commentId)) return;

    final index = state.replies.indexWhere((reply) {
      return reply.id.value == commentId;
    });

    if (index == -1) return;

    final originalReply = state.replies[index];
    final wasLiked = originalReply.isLiked;

    final optimisticReply = originalReply.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? (originalReply.likeCount - 1).clamp(0, 1 << 31)
          : originalReply.likeCount + 1,
    );

    _replaceReplyAt(
      index,
      optimisticReply,
      pendingLikeIds: {...state.pendingLikeIds, commentId},
    );

    final res = await api.toggleCommentLike(commentId: commentId);

    res.fold(
      (failure) {
        appLogger.e('❌ TOGGLE REPLY LIKE FAILED', error: failure);

        final rollbackIndex = state.replies.indexWhere((reply) {
          return reply.id.value == commentId;
        });

        final updatedPending = {...state.pendingLikeIds}..remove(commentId);

        if (rollbackIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        _replaceReplyAt(
          rollbackIndex,
          originalReply,
          pendingLikeIds: updatedPending,
        );
      },
      (result) {
        final syncIndex = state.replies.indexWhere((reply) {
          return reply.id.value == result.commentId;
        });

        final updatedPending = {...state.pendingLikeIds}..remove(commentId);

        if (syncIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        final currentReply = state.replies[syncIndex];

        final syncedReply = currentReply.copyWith(
          isLiked: result.liked,
          likeCount:
              result.likeCount ??
              _correctLikeCount(
                currentCount: currentReply.likeCount,
                currentlyLiked: currentReply.isLiked,
                serverLiked: result.liked,
              ),
        );

        _replaceReplyAt(syncIndex, syncedReply, pendingLikeIds: updatedPending);
      },
    );
  }

  // ───────────── DELETE REPLY ─────────────

  Future<void> deleteComment(String commentId) async {
    if (state.pendingDeleteIds.contains(commentId)) return;

    final index = state.replies.indexWhere((reply) {
      return reply.id.value == commentId;
    });

    if (index == -1) return;

    final targetReply = state.replies[index];

    if (!targetReply.canDelete && !targetReply.isOwner) {
      return;
    }

    final originalReplies = state.replies;

    final updatedReplies = state.replies
        .where((reply) {
          return reply.id.value != commentId;
        })
        .toList(growable: false);

    state = state.copyWith(
      replies: List.unmodifiable(updatedReplies),
      pendingDeleteIds: {...state.pendingDeleteIds, commentId},
    );

    final res = await api.deleteComment(commentId: commentId);

    res.fold(
      (failure) {
        appLogger.e('❌ DELETE REPLY FAILED', error: failure);

        final updatedPending = {...state.pendingDeleteIds}..remove(commentId);

        state = state.copyWith(
          replies: originalReplies,
          pendingDeleteIds: updatedPending,
        );
      },
      (_) {
        final updatedPending = {...state.pendingDeleteIds}..remove(commentId);

        state = state.copyWith(pendingDeleteIds: updatedPending);
      },
    );
  }

  // ───────────── HELPERS ─────────────

  void _insertReply(ShortComment reply) {
    state = state.copyWith(
      replies: List.unmodifiable([...state.replies, reply]),
    );
  }

  void _removeReply(String tempId) {
    state = state.copyWith(
      replies: List.unmodifiable(
        state.replies.where((reply) => reply.id.value != tempId).toList(),
      ),
    );
  }

  void _replaceReplyAt(
    int index,
    ShortComment updatedReply, {
    Set<String>? pendingLikeIds,
  }) {
    if (index < 0 || index >= state.replies.length) return;

    final updatedReplies = [...state.replies];
    updatedReplies[index] = updatedReply;

    state = state.copyWith(
      replies: List.unmodifiable(updatedReplies),
      pendingLikeIds: pendingLikeIds,
    );
  }

  int _correctLikeCount({
    required int currentCount,
    required bool currentlyLiked,
    required bool serverLiked,
  }) {
    if (currentlyLiked == serverLiked) return currentCount;

    return serverLiked
        ? currentCount + 1
        : (currentCount - 1).clamp(0, 1 << 31);
  }
}
