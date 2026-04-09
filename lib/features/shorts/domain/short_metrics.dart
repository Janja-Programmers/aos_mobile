import 'package:equatable/equatable.dart';

class ShortMetrics extends Equatable {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool likedByMe;

  const ShortMetrics({
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.likedByMe,
  });

  factory ShortMetrics.initial() {
    return const ShortMetrics(
      likeCount: 0,
      commentCount: 0,
      viewCount: 0,
      likedByMe: false,
    );
  }

  ShortMetrics copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? likedByMe,
  }) {
    return ShortMetrics(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  @override
  List<Object?> get props => [likeCount, commentCount, viewCount, likedByMe];
}
