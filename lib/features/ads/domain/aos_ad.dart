import 'package:africaonlinestores/features/ads/domain/aos_ad_image.dart';

class AOSAdListItem {
  const AOSAdListItem({
    required this.id,
    required this.title,
    required this.country,
    required this.locationName,
    required this.categoryName,
    required this.currentPrice,
    required this.originalPrice,
    required this.offerPercent,
    required this.isOfferActive,
    required this.priceType,
    required this.priceUnit,
    required this.primaryImage,
    required this.createdAt,
    required this.isWishlisted,
    required this.averageRating,
    required this.totalReviews,
  });

  final String id;
  final String title;
  final String country;
  final String locationName;
  final String categoryName;
  final String? currentPrice;
  final String? originalPrice;
  final double offerPercent;
  final bool isOfferActive;
  final String priceType;
  final String priceUnit;
  final String primaryImage;
  final DateTime? createdAt;
  final bool isWishlisted;
  final double averageRating;
  final int totalReviews;

  factory AOSAdListItem.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] is List)
        ? (json['images'] as List)
        : const [];

    String primary = (json['primary_image'] ?? json['image'] ?? '').toString();

    if (primary.isEmpty && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        primary = (first['image'] ?? '').toString();
      }
    }

    return AOSAdListItem(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location_name'] ?? json['location'] ?? '')
          .toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? '')
          .toString(),
      currentPrice: (json['current_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['current_price'].toString(),
      originalPrice: (json['original_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['original_price'].toString(),
      offerPercent: parseDouble(json['offer_percent']) ?? 0,
      isOfferActive: json['is_offer_active'] == true,
      priceType: (json['price_type'] ?? '').toString(),
      priceUnit: (json['price_unit'] ?? '').toString(),
      primaryImage: primary,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isWishlisted: json['is_wishlisted'] == true,
      averageRating: parseDouble(json['average_rating']) ?? 0.0,
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
    );
  }

  /// Draft serializer
  /// Draft serializer
  factory AOSAdListItem.fromDraft(Map<String, dynamic> json) {
    return AOSAdListItem(
      id: (json['id'] ?? json['name'] ?? '').toString(),

      /// drafts use hint fields
      title: (json['title'] ?? 'Untitled draft').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location'] ?? '').toString(),
      categoryName: (json['category'] ?? '').toString(),
      currentPrice: (json['current_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['current_price'].toString(),

      originalPrice: (json['original_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['original_price'].toString(),

      offerPercent: json['offer_percent'] ?? 0,
      isOfferActive: json['is_offer_active'] ?? false,
      priceType: (json['price_type'] ?? '').toString(),
      priceUnit: (json['price_unit'] ?? '').toString(),

      /// drafts usually have no image yet
      primaryImage: (json['primary_image'] ?? '').toString(),

      /// drafts use modified timestamp
      createdAt: json['modified'] != null
          ? DateTime.tryParse(json['modified'].toString())
          : null,

      isWishlisted: false,
      averageRating: 0,
      totalReviews: 0,
    );
  }
}

class AOSAdDetails {
  const AOSAdDetails({
    required this.id,
    required this.title,
    required this.status,
    required this.country,
    required this.locationName,
    required this.categoryName,
    required this.description,
    required this.currentPrice,
    required this.originalPrice,
    required this.offerPercent,
    required this.priceType,
    required this.priceUnit,
    required this.primaryImage,
    required this.isOfferActive,
    required this.isWishlisted,
    required this.averageRating,
    required this.totalReviews,
    required this.images,
    required this.imageItems,
    required this.video,
    required this.specs,
    required this.sellerId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String country;
  final String locationName;
  final String categoryName;
  final String? currentPrice;
  final String? originalPrice;
  final double offerPercent;
  final bool isOfferActive;
  final String priceType;
  final String priceUnit;
  final String primaryImage;
  final DateTime? createdAt;
  final bool isWishlisted;
  final double averageRating;
  final int totalReviews;
  final String description;
  final String sellerId;
  final List<String> images;

  /// Rich image items with File DocType id.
  final List<AOSAdImage> imageItems;

  final String? video;
  final List<Map<String, String>> specs;

  AOSAdImage? get primaryImageItem {
    if (imageItems.isEmpty) return null;

    final primary = imageItems.where((e) => e.isPrimary).toList();

    if (primary.isNotEmpty) {
      return primary.first;
    }

    if (primaryImage.trim().isNotEmpty) {
      return imageItems.firstWhere(
        (e) => e.image == primaryImage,
        orElse: () => imageItems.first,
      );
    }

    return imageItems.first;
  }

  String? get primaryImageFileId {
    final value = primaryImageItem?.fileId.trim();
    return value == null || value.isEmpty ? null : value;
  }

  factory AOSAdDetails.fromJson(Map<String, dynamic> json) {
    final imageItems = <AOSAdImage>[];
    final images = <String>[];

    if (json['images'] is List) {
      for (final e in (json['images'] as List)) {
        final item = AOSAdImage.fromJson(e);

        if (item.image.isNotEmpty) {
          imageItems.add(item);
          images.add(item.image);
        }
      }
    }

    final specs = <Map<String, String>>[];
    final rawSpecs = json['specs'] ?? json['details'] ?? json['attributes'];

    if (rawSpecs is List) {
      for (final e in rawSpecs) {
        if (e is Map) {
          final k =
              (e['label'] ?? e['attribute'] ?? e['name'] ?? e['key'] ?? '')
                  .toString();

          final text = (e['value'] ?? e['value_text'] ?? '').toString();
          final num = e['value_number'];
          final date = e['value_date'];
          final boolVal = e['value_bool'];

          String v = text.trim();

          if (v.isEmpty && num != null) v = num.toString();
          if (v.isEmpty && date != null) v = date.toString();

          if (v.isEmpty && boolVal != null) {
            final b = boolVal.toString().trim();
            if (b == '1') v = 'Yes';
            if (b == '0') v = 'No';
            if (v.isEmpty) v = b;
          }

          if (k.isNotEmpty && v.isNotEmpty) {
            specs.add({'label': k, 'value': v});
          }
        }
      }
    }

    String primary = (json['primary_image'] ?? json['image'] ?? '').toString();

    if (primary.isEmpty && imageItems.isNotEmpty) {
      final primaryItem = imageItems.where((e) => e.isPrimary).toList();
      primary = primaryItem.isNotEmpty
          ? primaryItem.first.image
          : imageItems.first.image;
    }

    return AOSAdDetails(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location_name'] ?? json['location'] ?? '')
          .toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? '')
          .toString(),
      currentPrice: (json['current_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['current_price'].toString(),
      originalPrice: (json['original_price'] ?? '').toString().trim().isEmpty
          ? null
          : json['original_price'].toString(),
      offerPercent: parseDouble(json['offer_percent']) ?? 0,
      isOfferActive: json['is_offer_active'] == true,
      priceType: (json['price_type'] ?? '').toString(),
      priceUnit: (json['price_unit'] ?? '').toString(),
      primaryImage: primary,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isWishlisted: json['is_wishlisted'] == true,
      averageRating: parseDouble(json['average_rating']) ?? 0.0,
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
      description: (json['description'] ?? '').toString(),
      sellerId: (json['seller'] ?? '').toString(),
      images: images,
      imageItems: imageItems,
      video: (json['video'] ?? '').toString().trim().isEmpty
          ? null
          : (json['video'] ?? '').toString(),
      specs: specs,
    );
  }
}

double? parseDouble(dynamic v) {
  if (v == null) return null;
  return double.tryParse(v.toString());
}
