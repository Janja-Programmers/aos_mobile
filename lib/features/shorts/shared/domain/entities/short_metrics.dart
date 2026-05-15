import 'package:equatable/equatable.dart';

class ShortMetrics extends Equatable {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final int impressionCount;
  final double rankingScore;

  const ShortMetrics({
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.shareCount,
    required this.impressionCount,
    required this.rankingScore,
  });

  factory ShortMetrics.initial() {
    return const ShortMetrics(
      likeCount: 0,
      commentCount: 0,
      viewCount: 0,
      shareCount: 0,
      impressionCount: 0,
      rankingScore: 0.0,
    );
  }

  ShortMetrics copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    int? shareCount,
    int? impressionCount,
    double? rankingScore,
  }) {
    return ShortMetrics(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      impressionCount: impressionCount ?? this.impressionCount,
      rankingScore: rankingScore ?? this.rankingScore,
    );
  }

  @override
  List<Object?> get props => [
    likeCount,
    commentCount,
    viewCount,
    shareCount,
    impressionCount,
    rankingScore,
  ];
}
