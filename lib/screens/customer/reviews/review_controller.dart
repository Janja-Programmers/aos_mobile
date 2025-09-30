import 'package:flutter/material.dart';

import '/features/reviews/entity.dart';
import '/features/reviews/remote.dart';

class ProductReviewsController extends ChangeNotifier {
  List<Review> reviews = [];
  double averageRating = 0.0;
  int totalReviews = 0;
  List<int> reviewsPerRating = [0, 0, 0, 0, 0];

  bool get hasReviews => reviews.isNotEmpty;
  bool isLoading = false;

  Future<void> loadReviews(String itemCode, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await fetchReviews(itemCode, context: context);

      reviews = response.toEntities();

      averageRating = response.averageRating;
      totalReviews = response.totalReviews;
      reviewsPerRating = response.reviewsPerRating;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
