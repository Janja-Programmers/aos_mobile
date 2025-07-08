import 'package:equatable/equatable.dart';
import 'package:ownashop/features/reviews/entity.dart';

import '/core/utils/formatters.dart';

import '/features/reviews/model.dart';

import '/shared/models/specifications.dart';

import '../domain/webitem.dart';

class WebsiteItemModel extends Equatable {
  final String? id;
  final String? owner;
  final String name;
  final String? image;
  final String? thumbnail;
  final String? demoVideoUrl;
  final String itemCode;
  final String? description;
  final String? title;
  final String? itemGroup;
  final String? shortDescription;
  final String? longDescription;
  final bool? onBackorder;
  final bool published;
  final double price;
  final bool inStock;
  final List<WebsiteSpecModel> specifications;
  final List<Review> reviews;

  const WebsiteItemModel({
    this.id,
    this.owner,
    required this.name,
    this.image,
    this.thumbnail,
    this.demoVideoUrl,
    required this.itemCode,
    this.description,
    this.title,
    this.itemGroup,
    this.shortDescription,
    this.longDescription,
    this.onBackorder,
    this.price = 0.0,
    this.inStock = true,
    required this.published,
    required this.specifications,
    this.reviews = const [],
  });

  factory WebsiteItemModel.fromJson(Map<String, dynamic> json) {
    return WebsiteItemModel(
      id: json['name'],
      owner: json['owner'],
      name: json['item_name'] ?? '',
      image: json['website_image'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      demoVideoUrl: json['custom_demo_video'],
      itemCode: json['item_code'] ?? '',
      description: json['short_description'] ?? '',
      title: json['title'] ?? '',
      itemGroup: json['category'] ?? '',
      shortDescription: json['short_description'] ?? '',
      longDescription:
          json['long_description'] is String
              ? cleanHtml(json['long_description'])
              : '',
      onBackorder: json['on_backorder'] == 1,
      published: json['published'] == 1,
      price: (json['price'] ?? 0).toDouble(),
      inStock: json['in_stock'] ?? false,
      specifications:
          (json['specifications'] as List<dynamic>?)
              ?.map((e) => WebsiteSpecModel.fromJson(e))
              .toList() ??
          [],
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e).toEntity())
              .toList() ??
          [],
    );
  }

  WebsiteItem toEntity() {
    return WebsiteItem(
      id: id ?? '',
      name: name,
      owner: owner ?? '',
      imageUrl: image ?? '',
      thumbnailUrl: thumbnail ?? '',
      demoVideoUrl: demoVideoUrl ?? '',
      itemCode: itemCode,
      description: description ?? '',
      published: published,
      specifications: specifications.map((e) => e.toEntity()).toList(),
      title: title ?? '',
      itemGroup: itemGroup ?? '',
      shortDescription: shortDescription ?? '',
      longDescription: longDescription ?? '',
      price: price,
      inStock: inStock,
      onBackorder: onBackorder ?? false,
      reviews: reviews,
    );
  }

  // --- NEW: Factory to build model from a domain entity ---
  factory WebsiteItemModel.fromEntity(WebsiteItem e) {
    return WebsiteItemModel(
      id: e.id,
      owner: e.owner,
      name: e.name,
      image: e.imageUrl,
      thumbnail: e.thumbnailUrl,
      demoVideoUrl: e.demoVideoUrl,
      itemCode: e.itemCode,
      description: e.description,
      title: e.title,
      itemGroup: e.itemGroup,
      shortDescription: e.shortDescription,
      longDescription: e.longDescription,
      onBackorder: e.onBackorder,
      published: e.published,
      price: e.price,
      inStock: e.inStock,
      specifications:
          e.specifications
              .map((s) => WebsiteSpecModel.fromJson(s as Map<String, dynamic>))
              .toList(),
      reviews: e.reviews,
    );
  }

  // --- JSON for POST/PUT to Frappe ---
  Map<String, dynamic> toJson() => {
    // Only include fields Frappe accepts/needs
    "item_name": name,
    "item_code": itemCode,
    "published": published ? 1 : 0,
    if (image?.isNotEmpty ?? false) "website_image": image,
    if (thumbnail?.isNotEmpty ?? false) "thumbnail": thumbnail,
    if (demoVideoUrl?.isNotEmpty ?? false) "custom_demo_video": demoVideoUrl,
    if (shortDescription?.isNotEmpty ?? false)
      "short_description": shortDescription,
    if (longDescription?.isNotEmpty ?? false)
      "web_long_description": longDescription,
    if (itemGroup?.isNotEmpty ?? false) "item_group": itemGroup,
    "on_backorder": onBackorder == true ? 1 : 0,
    "price": price,
    "in_stock": inStock,
    "website_specifications": specifications.map((s) => s.toEntity()).toList(),
    "reviews": reviews.map((r) => ReviewModel.fromEntity(r).toJson()).toList(),
  };

  @override
  List<Object?> get props => [id, name, itemCode];
}

class WebsiteSpecModel extends Equatable {
  final String label;
  final String description;

  const WebsiteSpecModel({required this.label, required this.description});

  factory WebsiteSpecModel.fromJson(Map<String, dynamic> json) {
    return WebsiteSpecModel(
      label: json['label'] ?? '',
      description: _extractTextFromHtml(json['value'] ?? ''),
    );
  }

  Specification toEntity() {
    return Specification(label: label, description: description);
  }

  static String _extractTextFromHtml(String html) {
    final tagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return html.replaceAll(tagRegExp, '').trim();
  }

  @override
  List<Object?> get props => [label, description];
}
