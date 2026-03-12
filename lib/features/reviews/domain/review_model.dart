class AdReview {
  const AdReview({
    required this.id,
    required this.rating,
    required this.title,
    required this.comment,
    required this.reviewer,
    required this.creation,
    required this.likeCount,
    required this.dislikeCount,
  });

  final String id;
  final double rating;
  final String title;
  final String comment;
  final String reviewer;
  final DateTime? creation;
  final int likeCount;
  final int dislikeCount;

  factory AdReview.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    return AdReview(
      id: (json['name'] ?? '').toString(),
      rating: parseDouble(json['rating']),
      title: (json['title'] ?? '').toString(),
      comment: (json['comment'] ?? '').toString(),
      reviewer: (json['reviewer'] ?? '').toString(),
      creation: json['creation'] != null
          ? DateTime.tryParse(json['creation'].toString())
          : null,
      likeCount: int.tryParse((json['like_count'] ?? 0).toString()) ?? 0,
      dislikeCount: int.tryParse((json['dislike_count'] ?? 0).toString()) ?? 0,
    );
  }
}
