import 'package:africaonlinestores/core/utils/json_utils.dart';

class SellerNearbyItem {
  const SellerNearbyItem({
    required this.seller,
    required this.displayName,
    this.user,
    this.avatar,
    this.businessCategory,
    this.sellerType,
    this.isVerified = false,
    this.ratingDisplay,
    this.reviewCountDisplay,
    this.locationName,
    this.locality,
    this.region,
    this.countryCode,
    this.distanceKm,
    this.distanceDisplay,
  });

  final String seller;
  final String? user;
  final String displayName;
  final String? avatar;
  final String? businessCategory;
  final String? sellerType;
  final bool isVerified;
  final String? ratingDisplay;
  final String? reviewCountDisplay;
  final String? locationName;
  final String? locality;
  final String? region;
  final String? countryCode;
  final double? distanceKm;
  final String? distanceDisplay;

  factory SellerNearbyItem.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? asJsonMap(json['location'] as Map)
        : const <String, dynamic>{};
    return SellerNearbyItem(
      seller: _string(json['seller']) ?? _string(json['name']) ?? '',
      user: _string(json['user']),
      displayName:
          _string(json['display_name']) ??
          _string(json['full_name']) ??
          _string(json['seller']) ??
          'Seller',
      avatar: _string(json['avatar']) ?? _string(json['user_image']),
      businessCategory: _string(json['business_category']),
      sellerType: _string(json['seller_type']),
      isVerified: _bool(json['is_verified']),
      ratingDisplay: _string(json['rating_display']) ?? _string(json['rating']),
      reviewCountDisplay:
          _string(json['review_count_display']) ??
          _string(json['reviews_display']) ??
          _string(json['total_reviews']),
      locationName:
          _string(location['name']) ?? _string(location['location_name']),
      locality: _string(location['locality']),
      region: _string(location['region']),
      countryCode: _string(location['country_code']),
      distanceKm: _double(location['distance_km']),
      distanceDisplay: _string(location['distance_display']),
    );
  }
}

String? _string(dynamic value) {
  final v = value?.toString().trim();
  if (v == null || v.isEmpty || v == 'null') return null;
  return v;
}

double? _double(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final clean = value?.toString().trim().toLowerCase();
  return clean == '1' || clean == 'true' || clean == 'yes';
}
