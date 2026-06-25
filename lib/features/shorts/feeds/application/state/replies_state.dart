import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class RepliesState {
  final List<ShortComment> replies;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final Set<String> pendingLikeIds;
  final Set<String> pendingDeleteIds;

  const RepliesState({
    required this.replies,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.nextCursor,
    required this.pendingLikeIds,
    required this.pendingDeleteIds,
  });

  factory RepliesState.initial() {
    return const RepliesState(
      replies: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: false,
      nextCursor: null,
      pendingLikeIds: {},
      pendingDeleteIds: {},
    );
  }

  RepliesState copyWith({
    List<ShortComment>? replies,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    bool clearNextCursor = false,
    Set<String>? pendingLikeIds,
    Set<String>? pendingDeleteIds,
  }) {
    return RepliesState(
      replies: replies ?? this.replies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      pendingLikeIds: pendingLikeIds ?? this.pendingLikeIds,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
    );
  }
}
