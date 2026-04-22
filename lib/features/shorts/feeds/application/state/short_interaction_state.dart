import 'package:equatable/equatable.dart';

class ShortInteractionState extends Equatable {
  /// currently liked shorts (by id)
  final Set<String> likedShortIds;

  /// shorts currently being processed for like/unlike
  final Set<String> pendingLikeActions;

  /// global mute/play state
  final bool isMuted;

  const ShortInteractionState({
    required this.likedShortIds,
    required this.pendingLikeActions,
    required this.isMuted,
  });

  factory ShortInteractionState.initial() {
    return const ShortInteractionState(
      likedShortIds: {},
      pendingLikeActions: {},
      isMuted: false,
    );
  }

  bool isLiked(String shortId) => likedShortIds.contains(shortId);

  bool isPending(String shortId) => pendingLikeActions.contains(shortId);

  ShortInteractionState copyWith({
    Set<String>? likedShortIds,
    Set<String>? pendingLikeActions,
    bool? isMuted,
  }) {
    return ShortInteractionState(
      likedShortIds: likedShortIds ?? this.likedShortIds,
      pendingLikeActions: pendingLikeActions ?? this.pendingLikeActions,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [likedShortIds, pendingLikeActions, isMuted];
}
