import 'package:equatable/equatable.dart';
import '../domain/item.dart';

class WebsiteItemModel extends Equatable {
  final String id;
  final String owner;
  final String name;
  final String image;
  final String thumbnail;
  final String itemCode;
  final String description;
  final String title;
  final String itemGroup;
  final String shortDescription;
  final String longDescription;
  final bool onBackorder;
  final bool published;
  final List<WebsiteSpecModel> specifications;

  const WebsiteItemModel({
    required this.id,
    required this.owner,
    required this.name,
    required this.image,
    required this.thumbnail,
    required this.itemCode,
    required this.description,
    required this.title,
    required this.itemGroup,
    required this.shortDescription,
    required this.longDescription,
    required this.onBackorder,
    required this.published,
    required this.specifications,
  });

  factory WebsiteItemModel.fromJson(Map<String, dynamic> json) {
    return WebsiteItemModel(
      id: json['name'],
      owner: json['owner'],
      name: json['item_name'] ?? '',
      image: json['website_image'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      itemCode: json['item_code'] ?? '',
      description: json['short_description'] ?? '',
      title: json['title'] ?? '',
      itemGroup: json['item_group'] ?? '',
      shortDescription: json['short_description'] ?? '',
      longDescription: json['long_description'] ?? '',
      onBackorder: json['on_backorder'] == 1,
      published: json['published'] == 1,
      specifications:
          (json['website_specifications'] as List<dynamic>?)
              ?.map((e) => WebsiteSpecModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  WebsiteItem toEntity() {
    return WebsiteItem(
      id: id,
      name: name,
      owner: owner,
      imageUrl: image,
      thumbnailUrl: thumbnail,
      itemCode: itemCode,
      description: description,
      published: published,
      specifications: specifications.map((e) => e.toEntity()).toList(),
      title: title,
      itemGroup: itemGroup,
      shortDescription: shortDescription,
      longDescription: longDescription,
      onBackorder: onBackorder,
    );
  }

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
      description: _extractTextFromHtml(json['description'] ?? ''),
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
