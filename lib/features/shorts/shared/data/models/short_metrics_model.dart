class ShortMetricsModel {
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final int shareCount;
  final int impressionCount;
  final double rankingScore;

  const ShortMetricsModel({
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
    required this.shareCount,
    required this.impressionCount,
    required this.rankingScore,
  });

  factory ShortMetricsModel.fromJson(Map<String, dynamic> json) {
    return ShortMetricsModel(
      likeCount: (json['like_count'] ?? 0).toInt(),
      viewCount: (json['view_count'] ?? 0).toInt(),
      commentCount: (json['comment_count'] ?? 0).toInt(),
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      impressionCount: (json['impression_count'] as num?)?.toInt() ?? 0,
      rankingScore: (json['ranking_score'] as num?)?.toDouble() ?? 0,
    );
  }
}
