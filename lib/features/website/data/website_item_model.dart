import '../domain/website_item.dart';

class WebsiteItemModel extends WebsiteItem {
  WebsiteItemModel({
    super.id,
    required super.websiteDisplayName,
    required super.itemCode,
    super.isPublished,
    required super.images,
    super.video,
    super.shortDescription,
    super.fullDescription,
    required super.createdBy,
    required super.createdAt,
  });

  factory WebsiteItemModel.fromJson(Map<String, dynamic> json) {
    return WebsiteItemModel(
      id: json['id'] as int?,
      websiteDisplayName: json['website_display_name'] as String,
      itemCode: json['item_code'] as String,
      isPublished: json['is_published'] == 1,
      images:
          json['images'] != null
              ? List<String>.from((json['images'] as String).split(','))
              : [],
      video: json['video'] as String?,
      shortDescription: json['short_description'] as String?,
      fullDescription: json['full_description'] as String?,
      createdBy: json['created_by'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'website_display_name': websiteDisplayName,
      'item_code': itemCode,
      'is_published': isPublished ? 1 : 0,
      'images': images.join(','),
      'video': video,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
