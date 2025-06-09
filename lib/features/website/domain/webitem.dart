import 'package:equatable/equatable.dart';

class WebsiteItem extends Equatable {
  final String id;
  final String name;
  final String owner;
  final String title;
  final String itemCode;
  final String itemGroup;
  final String thumbnailUrl;
  final String imageUrl;
  final String? demoVideoUrl;
  final String description;
  final String shortDescription;
  final String longDescription;
  final bool published;
  final bool onBackorder;
  final List<Specification> specifications;

  const WebsiteItem({
    required this.id,
    required this.name,
    required this.owner,
    required this.title,
    required this.itemCode,
    required this.itemGroup,
    required this.thumbnailUrl,
    required this.imageUrl,
    this.demoVideoUrl,
    required this.description,
    required this.shortDescription,
    required this.longDescription,
    required this.published,
    required this.onBackorder,
    required this.specifications,
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
    specifications,
  ];
}

class Specification extends Equatable {
  final String label;
  final String description;

  const Specification({required this.label, required this.description});

  @override
  List<Object> get props => [label, description];
}
