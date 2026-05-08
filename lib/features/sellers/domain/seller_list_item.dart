import 'package:equatable/equatable.dart';

class SellerListItem extends Equatable {
  const SellerListItem({
    required this.seller,
    required this.user,
    required this.shopName,
    required this.category,
    required this.avatar,
    required this.physicalAddress,
    required this.isVerified,
    required this.sellerType,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.isFollowing,
  });

  final String seller;
  final String user;
  final String shopName;
  final String? category;
  final String? avatar;
  final String? physicalAddress;
  final bool isVerified;
  final String sellerType;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final bool isFollowing;

  factory SellerListItem.fromJson(Map<String, dynamic> json) {
    return SellerListItem(
      seller: _string(json['seller']),
      user: _string(json['user']),
      shopName: _string(json['shop_name'], fallback: 'Unknown Seller'),
      category: _nullableString(json['category']),
      avatar: _nullableString(json['avatar']),
      physicalAddress: _nullableString(json['physical_address']),
      isVerified: _bool(json['is_verified']),
      sellerType: _string(json['seller_type'], fallback: 'Individual'),
      rating: _double(json['rating']),
      totalReviews: _int(json['total_reviews']),
      totalFollowers: _int(json['total_followers']),
      isFollowing: _bool(json['is_following']),
    );
  }

  String get displayCategory {
    final value = category?.trim();
    if (value == null || value.isEmpty) return sellerType;
    return value;
  }

  String get displayLocation {
    final value = physicalAddress?.trim();
    if (value == null || value.isEmpty) return 'Location not set';
    return value;
  }

  @override
  List<Object?> get props => [
    seller,
    user,
    shopName,
    category,
    avatar,
    physicalAddress,
    isVerified,
    sellerType,
    rating,
    totalReviews,
    totalFollowers,
    isFollowing,
  ];
}

String _string(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _int(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}
