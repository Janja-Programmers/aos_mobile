import 'package:equatable/equatable.dart';

import '/features/reviews/entity.dart';
import '/shared/models/specifications.dart';

class WebsiteItem extends Equatable {
  final String id;
  final String name;
  final String owner;
  final String title;
  final String itemCode;
  final String itemGroup;
  final String thumbnailUrl;
  final String imageUrl;
  final List<String> images;
  final String? demoVideoUrl;
  final String description;
  final String shortDescription;
  final String longDescription;
  final bool published;
  final bool onBackorder;
  final double price;
  final bool inStock;
  final List<Specification> specifications;
  final List<Review> reviews;

  const WebsiteItem({
    required this.id,
    required this.name,
    required this.owner,
    required this.title,
    required this.itemCode,
    required this.itemGroup,
    required this.thumbnailUrl,
    required this.imageUrl,
    this.images = const [],
    this.demoVideoUrl,
    required this.description,
    required this.shortDescription,
    required this.longDescription,
    required this.published,
    required this.onBackorder,
    this.price = 0.0,
    this.inStock = true,
    required this.specifications,
    this.reviews = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    owner,
    title,
    itemCode,
    itemGroup,
    thumbnailUrl,
    imageUrl,
    demoVideoUrl,
    description,
    shortDescription,
    longDescription,
    published,
    onBackorder,
    price,
    inStock,
    specifications,
    reviews,
  ];
}
