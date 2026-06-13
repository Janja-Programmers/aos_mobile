class AdReview {
  const AdReview({
    required this.id,
    required this.rating,
    required this.title,
    required this.comment,
    required this.reviewer,
    required this.creation,
    this.images = const [],
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
  final List<String> images;
  final bool isLiked;
  final bool isDisliked;
  final int likeCount;
  final int dislikeCount;

  factory AdReview.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }

    List<String> parseImages(dynamic value) {
      if (value is! List) return const [];

      return value
          .map((image) => image?.toString().trim() ?? '')
          .where((image) => image.isNotEmpty)
          .toList(growable: false);
    }

    final reviewerObject = json['reviewer'];
    final userReaction = (json['user_reaction'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final isLiked =
        parseBool(json['isLiked'] ?? json['is_liked']) ||
        userReaction == 'like';
    final isDisliked =
        parseBool(json['isDisliked'] ?? json['is_disliked']) ||
        userReaction == 'dislike';

    return AdReview(
      id: (json['id'] ?? '').toString(),
      rating: parseDouble(json['rating']),
      title: (json['title'] ?? '').toString(),
      comment: (json['comment'] ?? '').toString(),
      reviewer: reviewerObject is Map
          ? (reviewerObject['full_name'] ?? '').toString()
          : (reviewerObject ?? '').toString(),
      creation: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      images: parseImages(json['images']),
      likeCount: int.tryParse((json['like_count'] ?? 0).toString()) ?? 0,
      dislikeCount: int.tryParse((json['dislike_count'] ?? 0).toString()) ?? 0,
      isLiked: isLiked,
      isDisliked: isDisliked,
    );
  }

  AdReview copyWith({
    double? rating,
    String? title,
    String? comment,
    String? reviewer,
    DateTime? creation,
    List<String>? images,
    bool? isLiked,
    bool? isDisliked,
    int? likeCount,
    int? dislikeCount,
  }) {
    return AdReview(
      id: id,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      reviewer: reviewer ?? this.reviewer,
      creation: creation ?? this.creation,
      images: images ?? this.images,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
    );
  }
}
