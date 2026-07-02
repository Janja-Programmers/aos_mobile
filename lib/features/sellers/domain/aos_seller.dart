import 'package:africaonlinestores/core/utils/json_utils.dart';

class AOSSellerProfile {
  const AOSSellerProfile({
    required this.seller,
    required this.user,
    required this.displayName,
    required this.avatar,
    required this.businessCategory,
    required this.sellerType,
    required this.shopBanner,
    required this.aboutBusiness,
    required this.businessAddress,
    required this.isVerified,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalFollowing,
    required this.totalAds,
    required this.joined,
    required this.canEdit,
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    this.responseTimeSeconds,
    this.responseTimeDisplay,
    this.responseRate = 0,
    this.responseRateDisplay,
    this.responseSampleSize = 0,
    this.responseRequests = 0,
    this.responseMetricsUpdatedAt,
    required this.operatingHours,
  });

  final String seller;
  final String user;
  final String displayName;
  final String? avatar;
  final String? businessCategory;
  final String? sellerType;
  final String? shopBanner;
  final String? aboutBusiness;
  final String? businessAddress;
  final bool isVerified;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalFollowing;
  final int totalAds;
  final String joined;
  final bool canEdit;
  final String targetUser;
  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;
  final int? responseTimeSeconds;
  final String? responseTimeDisplay;
  final double responseRate;
  final String? responseRateDisplay;
  final int responseSampleSize;
  final int responseRequests;
  final String? responseMetricsUpdatedAt;
  final List<Object?> operatingHours;

  factory AOSSellerProfile.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    String parseString(dynamic v) {
      return (v ?? '').toString().trim();
    }

    String? parseNullableString(dynamic v) {
      final value = parseString(v);
      return value.isEmpty ? null : value;
    }

    final displayName = parseString(json['display_name']);

    return AOSSellerProfile(
      seller: parseString(json['seller']),
      user: parseString(json['user']),
      displayName: displayName.isNotEmpty ? displayName : 'Seller',
      avatar: parseNullableString(json['avatar']),
      businessCategory: parseNullableString(json['business_category']),
      sellerType: parseNullableString(json['seller_type']),
      shopBanner: parseNullableString(json['shop_banner']),
      aboutBusiness: parseNullableString(json['about_business']),
      businessAddress: parseNullableString(json['business_address']),
      isVerified: parseBool(json['is_verified']),
      rating: parseDouble(json['rating']),
      totalReviews: parseInt(json['total_reviews']),
      totalFollowers: parseInt(json['total_followers']),
      totalFollowing: parseInt(json['total_following']),
      totalAds: parseInt(json['total_ads']),
      joined: parseString(json['joined']),
      canEdit: parseBool(json['can_edit']),
      targetUser: parseString(json['target_user']),
      isSelf: parseBool(json['is_self']),
      isFollowing: parseBool(json['is_following']),
      isFollowedBy: parseBool(json['is_followed_by']),
      isFriend: parseBool(json['is_friend']),
      relationshipStatus: parseString(json['relationship_status']),
      actionLabel: parseString(json['action_label']),
      responseTimeSeconds: json['response_time_seconds'] == null
          ? null
          : parseInt(json['response_time_seconds']),
      responseTimeDisplay: parseNullableString(json['response_time_display']),
      responseRate: parseDouble(json['response_rate']),
      responseRateDisplay: parseNullableString(json['response_rate_display']),
      responseSampleSize: parseInt(json['response_sample_size']),
      responseRequests: parseInt(json['response_requests']),
      responseMetricsUpdatedAt: parseNullableString(
        json['response_metrics_updated_at'],
      ),
      operatingHours: asJsonList(json['operating_hours']),
    );
  }

  AOSSellerProfile copyWith({
    String? seller,
    String? user,
    String? displayName,
    String? avatar,
    String? businessCategory,
    String? sellerType,
    String? shopBanner,
    String? aboutBusiness,
    String? businessAddress,
    bool? isVerified,
    double? rating,
    int? totalReviews,
    int? totalFollowers,
    int? totalFollowing,
    int? totalAds,
    String? joined,
    bool? canEdit,
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    int? responseTimeSeconds,
    String? responseTimeDisplay,
    double? responseRate,
    String? responseRateDisplay,
    int? responseSampleSize,
    int? responseRequests,
    String? responseMetricsUpdatedAt,
    List<Object?>? operatingHours,
  }) {
    return AOSSellerProfile(
      seller: seller ?? this.seller,
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      businessCategory: businessCategory ?? this.businessCategory,
      sellerType: sellerType ?? this.sellerType,
      shopBanner: shopBanner ?? this.shopBanner,
      aboutBusiness: aboutBusiness ?? this.aboutBusiness,
      businessAddress: businessAddress ?? this.businessAddress,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      totalAds: totalAds ?? this.totalAds,
      joined: joined ?? this.joined,
      canEdit: canEdit ?? this.canEdit,
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      responseTimeDisplay: responseTimeDisplay ?? this.responseTimeDisplay,
      responseRate: responseRate ?? this.responseRate,
      responseRateDisplay: responseRateDisplay ?? this.responseRateDisplay,
      responseSampleSize: responseSampleSize ?? this.responseSampleSize,
      responseRequests: responseRequests ?? this.responseRequests,
      responseMetricsUpdatedAt:
          responseMetricsUpdatedAt ?? this.responseMetricsUpdatedAt,
      operatingHours: operatingHours ?? this.operatingHours,
    );
  }

  bool get hasAvatar => avatar != null;
  bool get hasBanner => shopBanner != null;
  bool get hasDescription => aboutBusiness != null;
  bool get hasBusinessAddress => businessAddress != null;
  bool get hasBusinessCategory => businessCategory != null;
  bool get hasOperatingHours => operatingHours.isNotEmpty;
}

bool parseBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v == 1;

  if (v is String) {
    final value = v.trim().toLowerCase();
    return value == '1' || value == 'true' || value == 'yes';
  }

  return false;
}
