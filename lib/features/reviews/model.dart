import 'package:equatable/equatable.dart';

import 'entity.dart';

class ReviewModel extends Equatable {
  final String title;
  final String customer;
  final String comment;
  final double rating;
  final String publishedOn;

  const ReviewModel({
    required this.title,
    required this.customer,
    required this.comment,
    required this.rating,
    required this.publishedOn,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      title: json['review_title'] ?? '',
      customer: json['user'] ?? '',
      comment: json['comment']?.trim() ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      publishedOn: json['published_on'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_title': title,
      'customer': customer,
      'comment': comment,
      'rating': rating,
      'published_on': publishedOn,
    };
  }

  Review toEntity() {
    return Review(
      title: title,
      customer: customer,
      comment: comment,
      rating: rating,
      publishedOn: publishedOn,
    );
  }

  static ReviewModel fromEntity(Review review) {
    return ReviewModel(
      title: review.title,
      customer: review.customer,
      comment: review.comment,
      rating: review.rating,
      publishedOn: review.publishedOn,
    );
  }

  @override
  List<Object?> get props => [title, customer, comment, rating, publishedOn];
}
