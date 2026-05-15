import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class CommentsState {
  final List<ShortComment> comments;
  final bool isLoading;
  final Set<String> pendingLikeIds;
  final Set<String> pendingDeleteIds;

  const CommentsState({
    required this.comments,
    required this.isLoading,
    required this.pendingLikeIds,
    required this.pendingDeleteIds,
  });

  factory CommentsState.initial() {
    return const CommentsState(
      comments: [],
      isLoading: false,
      pendingLikeIds: {},
      pendingDeleteIds: {},
    );
  }

  CommentsState copyWith({
    List<ShortComment>? comments,
    bool? isLoading,
    Set<String>? pendingLikeIds,
    Set<String>? pendingDeleteIds,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      pendingLikeIds: pendingLikeIds ?? this.pendingLikeIds,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
    );
  }
}
