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
  Map<int, int> get ratingDistribution {
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final ratingInt = r.rating.round().clamp(1, 5);
      dist[ratingInt] = (dist[ratingInt] ?? 0) + 1;
    }
    return dist;
  }
}
