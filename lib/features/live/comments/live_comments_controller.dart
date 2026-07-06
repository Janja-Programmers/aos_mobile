import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_mapper.dart';
import 'package:africaonlinestores/features/live/comments/live_comment_model.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final liveCommentsControllerProvider =
    StateNotifierProvider<LiveCommentsController, LiveCommentsState>((ref) {
      final api = ref.watch(liveCommentsApiProvider);
      return LiveCommentsController(api);
    });

class LiveCommentsController extends StateNotifier<LiveCommentsState> {
  final LiveCommentsApi api;

  LiveCommentsController(this.api) : super(LiveCommentsState.initial());

  String? get errorMessage => state.errorMessage;

  Future<void> init(String liveId) async {
    if (state.liveId != liveId) {
      state = LiveCommentsState.initial().copyWith(liveId: liveId);
    }

    if (state.comments.isNotEmpty || state.isLoading) return;

    appLogger.i('Init live comments → $liveId');
    await fetchComments(liveId);
  }

  void resetForLive(String liveId) {
    if (state.liveId == liveId && state.comments.isEmpty) return;
    state = LiveCommentsState.initial().copyWith(liveId: liveId);
  }

  void clear() {
    state = LiveCommentsState.initial();
  }

  Future<bool> addComment({
    required String liveId,
    required String comment,
    String? sessionId,
  }) async {
    final text = comment.trim();
    if (text.isEmpty) return false;

    if (state.liveId != liveId) {
      state = LiveCommentsState.initial().copyWith(liveId: liveId);
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final res = await api.addComment(
      liveId: liveId,
      comment: text,
      sessionId: sessionId,
    );

    return res.fold(
      (failure) {
        appLogger.e('Add live comment failed', error: failure);
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (comment) {
        _insertComment(comment);
        state = state.copyWith(isSubmitting: false, clearError: true);
        return true;
      },
    );
  }

  Future<void> fetchComments(String liveId) async {
    if (state.isLoading) return;

    if (state.liveId != liveId) {
      state = LiveCommentsState.initial().copyWith(liveId: liveId);
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await api.listComments(liveId: liveId);

      res.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (items) {
          state = state.copyWith(
            comments: _dedupe(items),
            isLoading: false,
            clearError: true,
          );
        },
      );
    } catch (e, s) {
      appLogger.e('fetch live comments failed', error: e, stackTrace: s);

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load live comments',
      );
    }
  }

  Future<void> deleteComment({required String commentId}) async {
    final previous = state.comments;

    state = state.copyWith(
      comments: state.comments.where((item) => item.id != commentId).toList(),
      clearError: true,
    );

    final res = await api.deleteComment(commentId: commentId);

    res.fold(
      (failure) {
        appLogger.e('Delete live comment failed', error: failure);
        state = state.copyWith(
          comments: previous,
          errorMessage: failure.message,
        );
      },
      (_) {
        appLogger.i('Live comment deleted');
      },
    );
  }

  void insertFromRealtime(Map<String, dynamic> json) {
    final payloadLiveId = json['live_id']?.toString();
    final raw = json['message'] ?? json['comment'] ?? json;
    if (raw is! Map) return;

    final rawMap = asJsonMap(raw);
    rawMap['live_id'] ??= payloadLiveId;

    final model = LiveCommentModel.fromJson(rawMap);
    if (model.id.isEmpty || model.isDeleted) return;

    final liveId = model.liveId.isNotEmpty ? model.liveId : payloadLiveId;
    if (liveId == null || liveId.isEmpty) return;
    if (state.liveId != liveId) return;

    _insertComment(LiveCommentMapper.toDomain(model));
  }

  void removeFromRealtime(String commentId) {
    _removeComments({commentId});
  }

  void removeManyFromRealtime(Iterable<String> commentIds) {
    _removeComments(commentIds.where((item) => item.isNotEmpty).toSet());
  }

  void _insertComment(LiveComment comment, {int limit = 80}) {
    if (state.liveId != null && comment.liveId != state.liveId) return;

    final withoutExisting = state.comments
        .where((item) => item.id != comment.id)
        .toList(growable: false);

    final updated = [comment, ...withoutExisting];

    state = state.copyWith(
      comments: updated.take(limit).toList(growable: false),
      clearError: true,
    );
  }

  void _removeComments(Set<String> ids) {
    if (ids.isEmpty) return;
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
      if (item.id.isEmpty || !seen.add(item.id)) continue;
      deduped.add(item);
    }

    return deduped;
  }
}
