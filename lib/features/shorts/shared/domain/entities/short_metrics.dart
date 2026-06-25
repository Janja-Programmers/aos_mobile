import 'package:equatable/equatable.dart';

class ShortMetrics extends Equatable {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final int saveCount;
  final int impressionCount;
  final int downloadCount;
  final int repostCount;
  final double rankingScore;

  const ShortMetrics({
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.shareCount,
    required this.saveCount,
    required this.impressionCount,
    required this.downloadCount,
    required this.repostCount,
    required this.rankingScore,
  });

  factory ShortMetrics.initial() {
    return const ShortMetrics(
      likeCount: 0,
      commentCount: 0,
      viewCount: 0,
      shareCount: 0,
      saveCount: 0,
      impressionCount: 0,
      downloadCount: 0,
      repostCount: 0,
      rankingScore: 0.0,
    );
  }

  ShortMetrics copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    int? shareCount,
    int? saveCount,
    int? impressionCount,
    int? downloadCount,
    int? repostCount,
    double? rankingScore,
  }) {
    return ShortMetrics(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      impressionCount: impressionCount ?? this.impressionCount,
      downloadCount: downloadCount ?? this.downloadCount,
      repostCount: repostCount ?? this.repostCount,
      rankingScore: rankingScore ?? this.rankingScore,
    );
  }

  @override
  List<Object?> get props => [
    likeCount,
    commentCount,
    viewCount,
    shareCount,
    saveCount,
    impressionCount,
    downloadCount,
    repostCount,
    rankingScore,
  ];
}
