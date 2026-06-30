sealed class SellerMapPoint {
  const SellerMapPoint({
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  final double latitude;
  final double longitude;
  final String type;

  factory SellerMapPoint.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    if (type == 'cluster') return SellerClusterPoint.fromJson(json);
    return SellerPinPoint.fromJson(json);
  }
}

class SellerClusterPoint extends SellerMapPoint {
  const SellerClusterPoint({
    required super.latitude,
    required super.longitude,
    required this.count,
  }) : super(type: 'cluster');

  final int count;

  factory SellerClusterPoint.fromJson(Map<String, dynamic> json) {
    return SellerClusterPoint(
      latitude: _double(json['latitude']) ?? 0,
      longitude: _double(json['longitude']) ?? 0,
      count: _int(json['count']) ?? 0,
    );
  }
}

class SellerPinPoint extends SellerMapPoint {
  const SellerPinPoint({
    required super.latitude,
    required super.longitude,
    required this.seller,
    this.user,
    this.displayName,
    this.avatar,
    this.businessCategory,
    this.sellerType,
    this.isVerified = false,
    this.locationName,
    this.locality,
    this.region,
    this.countryCode,
  }) : super(type: 'seller');

  final String seller;
  final String? user;
  final String? displayName;
  final String? avatar;
  final String? businessCategory;
  final String? sellerType;
  final bool isVerified;
  final String? locationName;
  final String? locality;
  final String? region;
  final String? countryCode;

  factory SellerPinPoint.fromJson(Map<String, dynamic> json) {
    return SellerPinPoint(
      latitude: _double(json['latitude']) ?? 0,
      longitude: _double(json['longitude']) ?? 0,
      seller: _string(json['seller']) ?? '',
      user: _string(json['user']),
      displayName: _string(json['display_name']) ?? _string(json['full_name']),
      avatar: _string(json['avatar']) ?? _string(json['user_image']),
      businessCategory: _string(json['business_category']),
      sellerType: _string(json['seller_type']),
      isVerified: _bool(json['is_verified']),
      locationName: _string(json['location_name']) ?? _string(json['name']),
      locality: _string(json['locality']),
      region: _string(json['region']),
      countryCode: _string(json['country_code']),
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

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final clean = value?.toString().trim().toLowerCase();
  return clean == '1' || clean == 'true' || clean == 'yes';
}
