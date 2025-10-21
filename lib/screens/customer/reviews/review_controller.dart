import 'package:flutter/material.dart';

import '/features/reviews/entity.dart';
import '/features/reviews/remote.dart';

class ProductReviewsController extends ChangeNotifier {
  final ReviewsRemote remote;
  ProductReviewsController({required this.remote});

  List<Review> reviews = [];
  double averageRating = 0.0;
  int totalReviews = 0;
  List<int> reviewsPerRating = [0, 0, 0, 0, 0];
  bool isLoading = false;

  bool get hasReviews => reviews.isNotEmpty;

  Future<void> loadReviews(String webItem) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await remote.fetchReviews(webItem);
      reviews = res.toEntities();
      averageRating = res.averageRating;
      totalReviews = res.totalReviews;
      reviewsPerRating = res.reviewsPerRating;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addLocalReview(Review review) {
    reviews.insert(0, review);
    totalReviews += 1;
    notifyListeners();
  }
}
