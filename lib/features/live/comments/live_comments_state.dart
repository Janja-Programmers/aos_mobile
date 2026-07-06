import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveCommentsState {
  final String? liveId;
  final List<LiveComment> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const LiveCommentsState({
    required this.liveId,
    required this.comments,
    required this.isLoading,
    required this.isSubmitting,
    required this.errorMessage,
  });

  factory LiveCommentsState.initial() {
    return const LiveCommentsState(
      liveId: null,
      comments: [],
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
    );
  }

  LiveCommentsState copyWith({
    String? liveId,
    bool clearLiveId = false,
    List<LiveComment>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveCommentsState(
      liveId: clearLiveId ? null : liveId ?? this.liveId,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
