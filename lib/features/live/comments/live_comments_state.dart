import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveCommentsState {
  const LiveCommentsState({
    required this.liveId,
    required this.comments,
    required this.nextCursor,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSubmitting,
    required this.deletingIds,
    required this.errorMessage,
  });

  final String? liveId;
  final List<LiveComment> comments;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final Set<String> deletingIds;
  final String? errorMessage;

  factory LiveCommentsState.initial() {
    return const LiveCommentsState(
      liveId: null,
      comments: <LiveComment>[],
      nextCursor: null,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
      isSubmitting: false,
      deletingIds: <String>{},
      errorMessage: null,
    );
  }

  LiveCommentsState copyWith({
    String? liveId,
    bool clearLiveId = false,
    List<LiveComment>? comments,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveCommentsState(
      liveId: clearLiveId ? null : liveId ?? this.liveId,
      comments: comments ?? this.comments,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
