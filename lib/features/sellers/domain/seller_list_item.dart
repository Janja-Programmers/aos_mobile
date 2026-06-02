import 'package:equatable/equatable.dart';

class SellerListItem extends Equatable {
  const SellerListItem({
    required this.seller,
    required this.user,
    required this.displayName,
    required this.avatar,
    required this.businessCategory,
    required this.businessAddress,
    required this.isVerified,
    required this.sellerType,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalFollowing,
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
  });

  final String seller;
  final String user;
  final String displayName;
  final String? avatar;

  final String? businessCategory;
  final String? businessAddress;

  final bool isVerified;
  final String sellerType;

  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalFollowing;

  final String targetUser;

  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;

  final String relationshipStatus;
  final String actionLabel;

  factory SellerListItem.fromJson(Map<String, dynamic> json) {
    return SellerListItem(
      seller: _string(json['seller']),
      user: _string(json['user']),
      displayName: _string(json['display_name'], fallback: 'Unknown Seller'),
      avatar: _nullableString(json['avatar']),
      businessCategory: _nullableString(json['business_category']),
      businessAddress: _nullableString(json['business_address']),
      isVerified: _bool(json['is_verified']),
      sellerType: _string(json['seller_type'], fallback: 'Individual'),
      rating: _double(json['rating']),
      totalReviews: _int(json['total_reviews']),
      totalFollowers: _int(json['total_followers']),
      totalFollowing: _int(json['total_following']),
      targetUser: _string(json['target_user']),
      isSelf: _bool(json['is_self']),
      isFollowing: _bool(json['is_following']),
      isFollowedBy: _bool(json['is_followed_by']),
      isFriend: _bool(json['is_friend']),
      relationshipStatus: _string(json['relationship_status']),
      actionLabel: _string(json['action_label'], fallback: 'Follow'),
    );
  }

  String get displayCategory {
    final value = businessCategory?.trim();
    if (value == null || value.isEmpty) return sellerType;
    return value;
  }

  String get displayLocation {
    final value = businessAddress?.trim();
    if (value == null || value.isEmpty) return 'Location not set';
    return value;
  }

  bool get canFollow {
    return !isSelf && !isFollowing;
  }

  bool get canFollowBack {
    return !isSelf && relationshipStatus == 'followed_by';
  }

  bool get showFriendsLabel {
    return isFriend || relationshipStatus == 'friends';
  }

  @override
  List<Object?> get props => [
    seller,
    user,
    displayName,
    avatar,
    businessCategory,
    businessAddress,
    isVerified,
    sellerType,
    rating,
    totalReviews,
    totalFollowers,
    totalFollowing,
    targetUser,
    isSelf,
    isFollowing,
    isFollowedBy,
    isFriend,
    relationshipStatus,
    actionLabel,
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
