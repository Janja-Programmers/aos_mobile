import 'entity.dart';
import 'model.dart';

class ReviewsResponseModel {
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;
  final List<int> reviewsPerRating;

  ReviewsResponseModel({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.reviewsPerRating,
  });

  factory ReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewsResponseModel(
      reviews:
          (json["reviews"] as List? ?? [])
              .map((e) => ReviewModel.fromJson(e))
              .toList(),
      averageRating: (json["average_rating"] ?? 0.0).toDouble(),
      totalReviews: json["total_reviews"] ?? 0,
      reviewsPerRating:
          (json["reviews_per_rating"] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0, 0, 0, 0, 0],
    );
  }

  List<Review> toEntities() => reviews.map((e) => e.toEntity()).toList();
}
