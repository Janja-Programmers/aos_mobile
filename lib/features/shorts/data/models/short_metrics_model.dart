class ShortMetricsModel {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final int impressionCount;

  const ShortMetricsModel({
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.shareCount,
    required this.impressionCount,
  });

  factory ShortMetricsModel.fromJson(Map<String, dynamic> json) {
    return ShortMetricsModel(
      likeCount: (json['like_count'] ?? 0) as int,
      commentCount: (json['comment_count'] ?? 0) as int,
      viewCount: (json['view_count'] ?? 0) as int,
      shareCount: (json['share_count'] ?? 0) as int,
      impressionCount: (json['impression_count'] ?? 0) as int,
    );
  }
}
