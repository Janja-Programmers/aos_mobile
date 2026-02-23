class AOSAdListItem {
  const AOSAdListItem({
    required this.id,
    required this.title,
    required this.country,
    required this.locationName,
    required this.categoryName,
    required this.currency,
    required this.priceType,
    required this.price,
    required this.priceUnit,
    required this.coverImage,
    required this.currentPrice,
    required this.offerPrice,
    required this.offerPercent,
    required this.isOfferActive,
    required this.priceDisplay,
    required this.imagesCount,
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
  final String currency;
  final String priceType;
  final double? price;
  final String priceUnit;
  final String coverImage;
  final double? currentPrice;
  final double? offerPrice;
  final double offerPercent;
  final bool isOfferActive;
  final String priceDisplay;
  final int imagesCount;
  final DateTime? createdAt;
  final bool isWishlisted;
  final double averageRating;
  final int totalReviews;

  factory AOSAdListItem.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    final images = (json['images'] is List)
        ? (json['images'] as List)
        : const [];

    String cover = (json['primary_image'] ?? json['image'] ?? '').toString();

    if (cover.isEmpty && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        cover = (first['image'] ?? '').toString();
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
      currency: (json['currency'] ?? '').toString(),
      priceType: (json['price_type'] ?? '').toString(),
      price: parseDouble(json['price']),
      priceUnit: (json['price_unit'] ?? '').toString(),
      coverImage: cover,
      currentPrice: parseDouble(json['current_price']),
      offerPrice: parseDouble(json['offer_price']),
      offerPercent: parseDouble(json['offer_percent']) ?? 0.0,
      isOfferActive: json['is_offer_active'] == true,
      priceDisplay: (json['price_display'] ?? '').toString(),
      imagesCount: int.tryParse((json['images_count'] ?? 0).toString()) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isWishlisted: json['is_wishlisted'] == true,
      averageRating: parseDouble(json['average_rating']) ?? 0.0,
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
    );
  }

  // 🔥 Helpful computed property
  bool get hasActiveOffer => isOfferActive && offerPercent > 0;
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
    required this.currency,
    required this.priceType,
    required this.price,
    required this.priceDisplay,
    required this.priceUnit,
    required this.images,
    required this.video,
    required this.specs,
    required this.currentPrice,
    required this.offerPrice,
    required this.offerPercent,
    required this.isOfferActive,
    required this.isWishlisted,
    required this.averageRating,
    required this.totalReviews,
    required this.imagesCount,
    required this.sellerId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String country;
  final String locationName;
  final String categoryName;
  final String description;
  final String currency;
  final String priceType;
  final double? price;
  final String priceDisplay;
  final String priceUnit;
  final List<String> images;
  final String? video;
  final List<Map<String, String>> specs;
  final double? currentPrice;
  final double? offerPrice;
  final double offerPercent;
  final bool isOfferActive;
  final bool isWishlisted;
  final double averageRating;
  final int totalReviews;
  final int imagesCount;
  final String sellerId;
  final DateTime? createdAt;

  factory AOSAdDetails.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    final images = <String>[];
    if (json['images'] is List) {
      for (final e in (json['images'] as List)) {
        if (e is Map) {
          final u = (e['image'] ?? '').toString();
          if (u.isNotEmpty) images.add(u);
        } else {
          final u = e.toString();
          if (u.isNotEmpty) images.add(u);
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

    return AOSAdDetails(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location_name'] ?? json['location'] ?? '')
          .toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? '')
          .toString(),
      description: (json['description'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      priceType: (json['price_type'] ?? '').toString(),
      price: parseDouble(json['price']),
      priceDisplay: (json['price_display'] ?? '').toString(),
      priceUnit: (json['price_unit'] ?? '').toString(),
      images: images,
      video: (json['video'] ?? '').toString().trim().isEmpty
          ? null
          : (json['video'] ?? '').toString(),
      specs: specs,
      currentPrice: parseDouble(json['current_price']),
      offerPrice: parseDouble(json['offer_price']),
      offerPercent: parseDouble(json['offer_percent']) ?? 0.0,
      isOfferActive: json['is_offer_active'] == true,
      isWishlisted: json['is_wishlisted'] == true,
      averageRating: parseDouble(json['average_rating']) ?? 0.0,
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
      imagesCount: int.tryParse((json['images_count'] ?? 0).toString()) ?? 0,
      sellerId: (json['seller'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get hasActiveOffer => isOfferActive && offerPercent > 0;
}
