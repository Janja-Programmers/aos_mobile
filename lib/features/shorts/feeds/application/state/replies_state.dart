import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class RepliesState {
  final List<ShortComment> replies;
  final bool isLoading;
  final Set<String> pendingLikeIds;
  final Set<String> pendingDeleteIds;

  const RepliesState({
    required this.replies,
    required this.isLoading,
    required this.pendingLikeIds,
    required this.pendingDeleteIds,
  });

  factory RepliesState.initial() {
    return const RepliesState(
      replies: [],
      isLoading: false,
      pendingLikeIds: {},
      pendingDeleteIds: {},
    );
  }

  RepliesState copyWith({
    List<ShortComment>? replies,
    bool? isLoading,
    Set<String>? pendingLikeIds,
    Set<String>? pendingDeleteIds,
  }) {
    return RepliesState(
      replies: replies ?? this.replies,
      isLoading: isLoading ?? this.isLoading,
      pendingLikeIds: pendingLikeIds ?? this.pendingLikeIds,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
    );
  }
}
