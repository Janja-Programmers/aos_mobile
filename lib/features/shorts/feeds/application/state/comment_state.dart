import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class CommentsState {
  final List<ShortComment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final Set<String> pendingLikeIds;
  final Set<String> pendingDeleteIds;

  const CommentsState({
    required this.comments,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.nextCursor,
    required this.pendingLikeIds,
    required this.pendingDeleteIds,
  });

  factory CommentsState.initial() {
    return const CommentsState(
      comments: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: false,
      nextCursor: null,
      pendingLikeIds: {},
      pendingDeleteIds: {},
    );
  }

  CommentsState copyWith({
    List<ShortComment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    bool clearNextCursor = false,
    Set<String>? pendingLikeIds,
    Set<String>? pendingDeleteIds,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      pendingLikeIds: pendingLikeIds ?? this.pendingLikeIds,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
    );
  }
}
