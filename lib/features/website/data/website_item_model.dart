import '../domain/website_item.dart';

class WebsiteItemModel extends WebsiteItem {
  WebsiteItemModel({
    super.id,
    required super.websiteDisplayName,
    required super.itemCode,
    super.isPublished,
    super.image,
    super.video,
    super.shortDescription,
    super.fullDescription,
    required super.createdBy,
    required super.createdAt, required super.images,
  });

  factory WebsiteItemModel.fromJson(Map<String, dynamic> json) {
    return WebsiteItemModel(
      id: json['id'] as int?,
      websiteDisplayName: json['website_display_name'] as String,
      itemCode: json['item_code'] as String,
      isPublished: json['is_published'] == 1,
      image: json['image'] as String?, // nullable
      video: json['video'] as String?,
      shortDescription: json['short_description'] as String?,
      fullDescription: json['full_description'] as String?,
      createdBy: json['created_by'] as int,
      createdAt: DateTime.parse(json['created_at'] as String), images: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'website_display_name': websiteDisplayName,
      'item_code': itemCode,
      'is_published': isPublished ? 1 : 0,
      'image': image, // store single image here
      'video': video,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
