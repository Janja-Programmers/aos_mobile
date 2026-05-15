class ShortMetricsModel {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final int impressionCount;
  final double rankingScore;

  const ShortMetricsModel({
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.shareCount,
    required this.impressionCount,
    required this.rankingScore,
  });

  factory ShortMetricsModel.initial() {
    return const ShortMetricsModel(
      likeCount: 0,
      commentCount: 0,
      viewCount: 0,
      shareCount: 0,
      impressionCount: 0,
      rankingScore: 0,
    );
  }

  factory ShortMetricsModel.fromJson(Map<String, dynamic> json) {
    return ShortMetricsModel(
      likeCount: _toInt(json['like_count']),
      commentCount: _toInt(json['comment_count']),
      viewCount: _toInt(json['view_count']),
      shareCount: _toInt(json['share_count']),
      impressionCount: _toInt(json['impression_count']),
      rankingScore: _toDouble(json['ranking_score']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
