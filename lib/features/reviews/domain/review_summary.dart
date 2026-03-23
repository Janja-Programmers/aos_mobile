class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    final rawDist = json['distribution'] as Map<String, dynamic>? ?? {};

    return ReviewSummary(
      averageRating: parseDouble(json['average_rating']),
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
      distribution: rawDist.map(
        (key, value) => MapEntry(
          int.tryParse(key) ?? 0,
          int.tryParse(value.toString()) ?? 0,
        ),
      ),
    );
  }
}
