import '/features/reviews/entity.dart';

/// Pure logic for the reviews UI.
/// Keeps all calculations outside the widget so the widget only renders.
class ProductReviewsController {
  final List<Review> reviews;

  ProductReviewsController({required this.reviews});

  bool get hasReviews => reviews.isNotEmpty;
  int get totalReviews => reviews.length;

  /// Average rating as double (0.0 - 5.0). Returns 0.0 when no reviews.
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (prev, r) => prev + r.rating);
    return sum / reviews.length;
  }

  /// Distribution map: keys 1..5 -> counts
  /// Distribution map: keys 0.5, 1.0, ..., 5.0 -> counts
Map<double, int> get ratingDistribution {
  final dist = {
    for (var i = 1; i <= 10; i++) i * 0.5: 0,
  };

  for (final r in reviews) {
    // Round to nearest 0.5
    final bucket = (r.rating * 2).round() / 2.0;
    dist[bucket] = (dist[bucket] ?? 0) + 1;
  }
  return dist;
}

}
