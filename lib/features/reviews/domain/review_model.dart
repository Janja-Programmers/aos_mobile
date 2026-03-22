class AdReview {
  const AdReview({
    required this.id,
    required this.rating,
    required this.title,
    required this.comment,
    required this.reviewer,
    required this.creation,
    this.isLiked = false,
    this.isDisliked = false,
    required this.likeCount,
    required this.dislikeCount,
  });

  final String id;
  final double rating;
  final String title;
  final String comment;
  final String reviewer;
  final DateTime? creation;
  final bool isLiked;
  final bool isDisliked;
  final int likeCount;
  final int dislikeCount;

  factory AdReview.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    final reviewerObj = json['reviewer'];

    return AdReview(
      id: (json['id'] ?? '').toString(),
      rating: parseDouble(json['rating']),
      title: (json['title'] ?? '').toString(),
      comment: (json['comment'] ?? '').toString(),
      reviewer: reviewerObj is Map
          ? (reviewerObj['full_name'] ?? '')
          : (reviewerObj ?? '').toString(),
      creation: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      likeCount: int.tryParse((json['like_count'] ?? 0).toString()) ?? 0,
      dislikeCount: int.tryParse((json['dislike_count'] ?? 0).toString()) ?? 0,
    );
  }
}
