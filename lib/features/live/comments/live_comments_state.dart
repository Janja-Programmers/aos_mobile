import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/live/comments/live_comment.dart';

@immutable
class LiveCommentsState {
  final List<LiveComment> comments;
  final bool isLoading;
  final String? errorMessage;

  const LiveCommentsState({
    required this.comments,
    required this.isLoading,
    required this.errorMessage,
  });

  factory LiveCommentsState.initial() {
    return const LiveCommentsState(
      comments: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  LiveCommentsState copyWith({
    List<LiveComment>? comments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
