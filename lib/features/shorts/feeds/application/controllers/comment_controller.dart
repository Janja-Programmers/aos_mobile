import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/comment_state.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';

class CommentsController extends StateNotifier<CommentsState> {
  final ShortsCommentsApi api;

  CommentsController(this.api) : super(CommentsState.initial());

  String? _activeShortId;

  // ───────────── Initial COMMENT ─────────────

  Future<void> init(String shortId) async {
    if (_activeShortId == shortId && state.comments.isNotEmpty) return;

    _activeShortId = shortId;

    state = state.copyWith(comments: []);

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
      displayName: "You",
      avatar: null,
      comment: comment,
      parentId: null,
      rootId: null,
      replyCount: 0,
      likeCount: 0,
      isLiked: false,
      isOwner: true,
      canDelete: true,
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

    state = state.copyWith(isLoading: true);

    try {
      final res = await api.listComments(shortId: shortId);

      res.fold(
        (e) {
          state = state.copyWith(comments: [], isLoading: false);
        },
        (items) {
          state = state.copyWith(comments: items, isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(comments: [], isLoading: false);
    }
  }

  // ───────────── LIKE COMMENTS ─────────────

  Future<void> toggleCommentLike(String commentId) async {
    if (state.pendingLikeIds.contains(commentId)) return;

    final index = state.comments.indexWhere((c) => c.id.value == commentId);
    if (index == -1) return;

    final originalComment = state.comments[index];
    final wasLiked = originalComment.isLiked;

    final optimisticComment = originalComment.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? (originalComment.likeCount - 1).clamp(0, 1 << 31)
          : originalComment.likeCount + 1,
    );

    _replaceCommentAt(
      index,
      optimisticComment,
      pendingLikeIds: {...state.pendingLikeIds, commentId},
    );

    final res = await api.toggleCommentLike(commentId: commentId);

    res.fold(
      (failure) {
        appLogger.e('❌ TOGGLE COMMENT LIKE FAILED', error: failure);

        final rollbackIndex = state.comments.indexWhere(
          (c) => c.id.value == commentId,
        );

        final updatedPending = {...state.pendingLikeIds}..remove(commentId);

        if (rollbackIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        _replaceCommentAt(
          rollbackIndex,
          originalComment,
          pendingLikeIds: updatedPending,
        );
      },
      (result) {
        final syncIndex = state.comments.indexWhere(
          (c) => c.id.value == result.commentId,
        );

        final updatedPending = {...state.pendingLikeIds}..remove(commentId);

        if (syncIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        final current = state.comments[syncIndex];

        final synced = current.copyWith(
          isLiked: result.liked,
          likeCount:
              result.likeCount ??
              _correctLikeCount(
                currentCount: current.likeCount,
                currentlyLiked: current.isLiked,
                serverLiked: result.liked,
              ),
        );

        _replaceCommentAt(syncIndex, synced, pendingLikeIds: updatedPending);
      },
    );
  }

  // ───────────── DELETE COMMENTS ─────────────

  Future<void> deleteComment(String commentId) async {
    if (state.pendingDeleteIds.contains(commentId)) return;

    final index = state.comments.indexWhere((c) => c.id.value == commentId);
    if (index == -1) return;

    final originalComments = state.comments;

    final target = state.comments[index];

    if (!target.canDelete && !target.isOwner) {
      return;
    }

    final updatedComments = state.comments
        .where((comment) => comment.id.value != commentId)
        .toList(growable: false);

    state = state.copyWith(
      comments: List.unmodifiable(updatedComments),
      pendingDeleteIds: {...state.pendingDeleteIds, commentId},
    );

    final res = await api.deleteComment(commentId: commentId);

    res.fold(
      (failure) {
        appLogger.e('❌ DELETE COMMENT FAILED', error: failure);

        final updatedPending = {...state.pendingDeleteIds}..remove(commentId);

        state = state.copyWith(
          comments: originalComments,
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

  void _insertComment(ShortComment comment) {
    state = state.copyWith(comments: [comment, ...state.comments]);
  }

  void _removeComment(String tempId) {
    state = state.copyWith(
      comments: state.comments.where((c) => c.id.value != tempId).toList(),
    );
  }

  void _replaceCommentAt(
    int index,
    ShortComment updatedComment, {
    Set<String>? pendingLikeIds,
  }) {
    if (index < 0 || index >= state.comments.length) return;

    final updatedComments = [...state.comments];
    updatedComments[index] = updatedComment;

    state = state.copyWith(
      comments: List.unmodifiable(updatedComments),
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
