import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String title;
  final String customer;
  final String comment;
  final double rating;
  final String publishedOn;

  const Review({
    required this.title,
    required this.customer,
    required this.comment,
    required this.rating,
    required this.publishedOn,
  });

  @override
  List<Object?> get props => [title, customer, comment, rating, publishedOn];
}
