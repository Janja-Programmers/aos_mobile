import 'dart:collection';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_mapper.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_state.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

final liveCommentsControllerProvider =
    StateNotifierProvider<LiveCommentsController, LiveCommentsState>((ref) {
      return LiveCommentsController(ref.watch(liveCommentsApiProvider));
    });

class LiveCommentsController extends StateNotifier<LiveCommentsState> {
  LiveCommentsController(this.api) : super(LiveCommentsState.initial());

  static const Uuid _uuid = Uuid();
  static const int _memoryLimit = 250;

  final LiveCommentsApi api;
  final LinkedHashSet<String> _deletedIds = LinkedHashSet<String>();
  int _generation = 0;

  String? get errorMessage => state.errorMessage;

  Future<void> init(String liveId) async {
    if (state.liveId != liveId) resetForLive(liveId);
    if (state.comments.isNotEmpty || state.isLoading) return;
    await fetchComments(liveId);
  }

  void resetForLive(String liveId) {
    if (state.liveId == liveId && state.comments.isEmpty) return;
    ++_generation;
    _deletedIds.clear();
    state = LiveCommentsState.initial().copyWith(liveId: liveId);
  }

  void clear() {
    ++_generation;
    _deletedIds.clear();
    state = LiveCommentsState.initial();
  }

  Future<void> fetchComments(String liveId) async {
    if (state.isLoading) return;
    if (state.liveId != liveId) resetForLive(liveId);
    final generation = _generation;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await api.listComments(liveId: liveId);
    if (!mounted || generation != _generation || state.liveId != liveId) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (page) {
        state = state.copyWith(
          comments: _dedupe(<LiveComment>[...page.items, ...state.comments]),
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          hasMore: page.hasMore,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  Future<void> loadMore() async {
    final liveId = state.liveId;
    final cursor = state.nextCursor?.trim() ?? '';
    if (liveId == null ||
        cursor.isEmpty ||
        !state.hasMore ||
        state.isLoading ||
        state.isLoadingMore) {
      return;
    }

    final generation = _generation;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    final result = await api.listComments(liveId: liveId, cursor: cursor);
    if (!mounted || generation != _generation || state.liveId != liveId) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (page) {
        state = state.copyWith(
          comments: _dedupe(<LiveComment>[...state.comments, ...page.items]),
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        );
      },
    );
  }

  Future<bool> addComment({
    required String liveId,
    required String comment,
    String? sessionId,
  }) {
    return _submit(
      liveId: liveId,
      comment: comment,
      sessionId: sessionId,
      parentMessageId: null,
    );
  }

  Future<bool> replyComment({
    required String liveId,
    required String parentMessageId,
    required String comment,
    String? sessionId,
  }) {
    return _submit(
      liveId: liveId,
      comment: comment,
      sessionId: sessionId,
      parentMessageId: parentMessageId,
    );
  }

  Future<bool> _submit({
    required String liveId,
    required String comment,
    required String? sessionId,
    required String? parentMessageId,
  }) async {
    final text = comment.trim();
    if (text.isEmpty || state.isSubmitting) return false;
    if (state.liveId != liveId) resetForLive(liveId);

    final generation = _generation;
    state = state.copyWith(isSubmitting: true, clearError: true);
    final key = _uuid.v4();
    final result = parentMessageId == null
        ? await api.addComment(
            liveId: liveId,
            comment: text,
            sessionId: sessionId,
            idempotencyKey: key,
          )
        : await api.replyComment(
            liveId: liveId,
            parentMessageId: parentMessageId,
            comment: text,
            sessionId: sessionId,
            idempotencyKey: key,
          );

    if (!mounted || generation != _generation || state.liveId != liveId) {
      return false;
    }

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (submitted) {
        _insertComment(submitted);
        state = state.copyWith(isSubmitting: false, clearError: true);
        return true;
      },
    );
  }

  Future<bool> deleteComment({required String commentId}) async {
    final id = commentId.trim();
    if (id.isEmpty || state.deletingIds.contains(id)) return false;

    final generation = _generation;
    final previous = state.comments;
    final optimisticIds = _knownBranchIds(id, previous);
    final deleting = <String>{...state.deletingIds, id};
    state = state.copyWith(
      comments: previous
          .where((comment) => !optimisticIds.contains(comment.id))
          .toList(growable: false),
      deletingIds: Set<String>.unmodifiable(deleting),
      clearError: true,
    );

    final result = await api.deleteComment(commentId: id);
    if (!mounted || generation != _generation) return false;

    return result.fold(
      (failure) {
        final nextDeleting = <String>{...state.deletingIds}..remove(id);
        state = state.copyWith(
          comments: _dedupe(<LiveComment>[...previous, ...state.comments]),
          deletingIds: Set<String>.unmodifiable(nextDeleting),
          errorMessage: failure.message,
        );
        return false;
      },
      (serverDeletedIds) {
        final deleted = <String>{...optimisticIds, ...serverDeletedIds};
        for (final deletedId in deleted) {
          _rememberDeleted(deletedId);
        }
        final nextDeleting = <String>{...state.deletingIds}..remove(id);
        state = state.copyWith(
          comments: state.comments
              .where((comment) => !deleted.contains(comment.id))
              .toList(growable: false),
          deletingIds: Set<String>.unmodifiable(nextDeleting),
          clearError: true,
        );
        return true;
      },
    );
  }

  void insertFromRealtime(Map<String, dynamic> json) {
    final payloadLiveId = json['live_id']?.toString();
    final raw = json['message'] ?? json['comment'] ?? json;
    if (raw is! Map<Object?, Object?>) return;

    final rawMap = asJsonMap(raw);
    rawMap['live_id'] ??= payloadLiveId;
    final model = LiveCommentModel.fromJson(rawMap);
    if (model.id.isEmpty || model.isDeleted) return;

    final liveId = model.liveId.isNotEmpty ? model.liveId : payloadLiveId;
    if (liveId == null || liveId.isEmpty || state.liveId != liveId) return;
    _insertComment(LiveCommentMapper.toDomain(model));
  }

  void removeFromRealtime(String commentId) {
    _removeComments(<String>{commentId});
  }

  void removeManyFromRealtime(Iterable<String> commentIds) {
    _removeComments(
      commentIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet(),
    );
  }

  void _insertComment(LiveComment comment) {
    if (state.liveId != null && comment.liveId != state.liveId) return;
    if (_deletedIds.contains(comment.id)) return;

    final exists = state.comments.any((item) => item.id == comment.id);
    var updated = state.comments
        .where((item) => item.id != comment.id)
        .toList(growable: true);

    if (!exists && comment.isReply && comment.parentId != null) {
      updated = updated
          .map(
            (item) => item.id == comment.parentId
                ? item.copyWith(replyCount: item.replyCount + 1)
                : item,
          )
          .toList(growable: true);
    }

    updated.insert(0, comment);
    state = state.copyWith(
      comments: updated.take(_memoryLimit).toList(growable: false),
      clearError: true,
    );
  }

  Set<String> _knownBranchIds(String rootId, List<LiveComment> comments) {
    final ids = <String>{rootId};
    var changed = true;
    while (changed) {
      changed = false;
      for (final comment in comments) {
        if (ids.contains(comment.id)) continue;
        final parent = comment.parentId;
        if (parent != null && ids.contains(parent)) {
          ids.add(comment.id);
          changed = true;
        }
      }
    }
    return ids;
  }

  void _removeComments(Set<String> ids) {
    if (ids.isEmpty) return;
    for (final id in ids) {
      _rememberDeleted(id);
    }
    state = state.copyWith(
      comments: state.comments
          .where((item) => !ids.contains(item.id))
          .toList(growable: false),
    );
  }

  List<LiveComment> _dedupe(List<LiveComment> items) {
    final seen = <String>{};
    final deduped = <LiveComment>[];
    for (final item in items) {
      if (item.id.isEmpty ||
          _deletedIds.contains(item.id) ||
          !seen.add(item.id)) {
        continue;
      }
      deduped.add(item);
      if (deduped.length == _memoryLimit) break;
    }
    return deduped;
  }

  void _rememberDeleted(String id) {
    if (id.isEmpty) return;
    _deletedIds.add(id);
    while (_deletedIds.length > 512) {
      _deletedIds.remove(_deletedIds.first);
    }
  }
}
