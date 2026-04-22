class ShortMetricsModel {
  final int likes;
  final int views;
  final int comments;
  final int shares;

  const ShortMetricsModel({
    required this.likes,
    required this.views,
    required this.comments,
    required this.shares,
  });

  factory ShortMetricsModel.fromJson(Map<String, dynamic> json) {
    return ShortMetricsModel(
      likes: (json['like_count'] ?? 0).toInt(),
      views: (json['view_count'] ?? 0).toInt(),
      comments: (json['comment_count'] ?? 0).toInt(),
      shares: (json['share_count'] ?? 0).toInt(),
    );
  }
}
