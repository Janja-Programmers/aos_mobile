import 'package:africaonlinestores/core/utils/json_utils.dart';

class AOSSellerProfile {
  const AOSSellerProfile({
    required this.seller,
    required this.user,
    required this.displayName,
    required this.avatar,
    required this.isDeleted,
    required this.businessCategory,
    required this.sellerType,
    required this.shopBanner,
    required this.shopBannerMediaId,
    required this.aboutBusiness,
    required this.businessAddress,
    required this.isVerified,
    required this.location,
    required this.rating,
    required this.ratingDisplay,
    required this.totalReviews,
    required this.totalReviewsDisplay,
    required this.totalFollowers,
    required this.totalFollowersDisplay,
    required this.totalFollowing,
    required this.totalFollowingDisplay,
    required this.totalFriends,
    required this.totalFriendsDisplay,
    required this.totalAds,
    required this.totalAdsDisplay,
    required this.joined,
    required this.canEdit,
    required this.targetUser,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    required this.isBlockedByMe,
    required this.hasBlockedMe,
    required this.isBlocked,
    required this.blockStatus,
    required this.canFollow,
    required this.canMessage,
    required this.canCall,
    required this.canViewProfile,
    required this.isLive,
    this.liveId,
    this.liveStatus,
    this.liveTitle,
    this.liveCoverImage,
    this.liveStartedAt,
    this.liveViewerCount = 0,
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
  final bool isDeleted;
  final String? businessCategory;
  final String? sellerType;
  final String? shopBanner;
  final String? shopBannerMediaId;
  final String? aboutBusiness;
  final String? businessAddress;
  final bool isVerified;
  final AOSSellerLocation? location;
  final double rating;
  final String? ratingDisplay;
  final int totalReviews;
  final String? totalReviewsDisplay;
  final int totalFollowers;
  final String? totalFollowersDisplay;
  final int totalFollowing;
  final String? totalFollowingDisplay;
  final int totalFriends;
  final String? totalFriendsDisplay;
  final int totalAds;
  final String? totalAdsDisplay;
  final String joined;
  final bool canEdit;
  final String targetUser;
  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;
  final bool isBlockedByMe;
  final bool hasBlockedMe;
  final bool isBlocked;
  final String blockStatus;
  final bool canFollow;
  final bool canMessage;
  final bool canCall;
  final bool canViewProfile;
  final bool isLive;
  final String? liveId;
  final String? liveStatus;
  final String? liveTitle;
  final String? liveCoverImage;
  final String? liveStartedAt;
  final int liveViewerCount;
  final int? responseTimeSeconds;
  final String? responseTimeDisplay;
  final double responseRate;
  final String? responseRateDisplay;
  final int responseSampleSize;
  final int responseRequests;
  final String? responseMetricsUpdatedAt;
  final List<Object?> operatingHours;

  factory AOSSellerProfile.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic v) {
      return (v ?? '').toString().trim();
    }

    String? parseNullableString(dynamic v) {
      final value = parseString(v);
      return value.isEmpty || value == 'null' ? null : value;
    }

    final displayName = parseString(json['display_name']);
    final location = AOSSellerLocation.fromJsonOrNull(json['location']);

    return AOSSellerProfile(
      seller: parseString(json['seller']),
      user: parseString(json['user']),
      displayName: displayName.isNotEmpty ? displayName : 'Seller',
      avatar: parseNullableString(json['avatar']),
      isDeleted: parseBool(json['is_deleted']),
      businessCategory: parseNullableString(json['business_category']),
      sellerType: parseNullableString(json['seller_type']),
      shopBanner: parseNullableString(json['shop_banner']),
      shopBannerMediaId:
          parseNullableString(json['shop_banner_media_id']) ??
          parseNullableString(json['shop_banner_media']),
      aboutBusiness: parseNullableString(json['about_business']),
      businessAddress:
          parseNullableString(json['business_address']) ??
          location?.displayAddress,
      isVerified: parseBool(json['is_verified']),
      location: location,
      rating: asDouble(json['rating']),
      ratingDisplay: parseNullableString(json['rating_display']),
      totalReviews: asInt(json['total_reviews']),
      totalReviewsDisplay: parseNullableString(json['total_reviews_display']),
      totalFollowers: asInt(json['total_followers']),
      totalFollowersDisplay: parseNullableString(
        json['total_followers_display'],
      ),
      totalFollowing: asInt(json['total_following']),
      totalFollowingDisplay: parseNullableString(
        json['total_following_display'],
      ),
      totalFriends: asInt(json['total_friends']),
      totalFriendsDisplay: parseNullableString(json['total_friends_display']),
      totalAds: asInt(json['total_ads']),
      totalAdsDisplay: parseNullableString(json['total_ads_display']),
      joined: parseString(json['joined']),
      canEdit: parseBool(json['can_edit']),
      targetUser: parseString(json['target_user']),
      isSelf: parseBool(json['is_self']),
      isFollowing: parseBool(json['is_following']),
      isFollowedBy: parseBool(json['is_followed_by']),
      isFriend: parseBool(json['is_friend']),
      relationshipStatus: parseString(json['relationship_status']),
      actionLabel: parseString(json['action_label']),
      isBlockedByMe: parseBool(json['is_blocked_by_me']),
      hasBlockedMe: parseBool(json['has_blocked_me']),
      isBlocked: parseBool(json['is_blocked']),
      blockStatus: parseString(json['block_status']),
      canFollow: parseBool(json['can_follow'], fallback: true),
      canMessage: parseBool(json['can_message'], fallback: true),
      canCall: parseBool(json['can_call'], fallback: true),
      canViewProfile: parseBool(json['can_view_profile'], fallback: true),
      isLive: parseBool(json['is_live']),
      liveId: parseNullableString(json['live_id']),
      liveStatus: parseNullableString(json['live_status']),
      liveTitle: parseNullableString(json['live_title']),
      liveCoverImage: parseNullableString(json['live_cover_image']),
      liveStartedAt: parseNullableString(json['live_started_at']),
      liveViewerCount: asInt(json['live_viewer_count']),
      responseTimeSeconds: json['response_time_seconds'] == null
          ? null
          : asInt(json['response_time_seconds']),
      responseTimeDisplay: parseNullableString(json['response_time_display']),
      responseRate: asDouble(json['response_rate']),
      responseRateDisplay: parseNullableString(json['response_rate_display']),
      responseSampleSize: asInt(json['response_sample_size']),
      responseRequests: asInt(json['response_requests']),
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
    bool? isDeleted,
    String? businessCategory,
    String? sellerType,
    String? shopBanner,
    String? shopBannerMediaId,
    String? aboutBusiness,
    String? businessAddress,
    bool? isVerified,
    AOSSellerLocation? location,
    double? rating,
    String? ratingDisplay,
    int? totalReviews,
    String? totalReviewsDisplay,
    int? totalFollowers,
    String? totalFollowersDisplay,
    int? totalFollowing,
    String? totalFollowingDisplay,
    int? totalFriends,
    String? totalFriendsDisplay,
    int? totalAds,
    String? totalAdsDisplay,
    String? joined,
    bool? canEdit,
    String? targetUser,
    bool? isSelf,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isFriend,
    String? relationshipStatus,
    String? actionLabel,
    bool? isBlockedByMe,
    bool? hasBlockedMe,
    bool? isBlocked,
    String? blockStatus,
    bool? canFollow,
    bool? canMessage,
    bool? canCall,
    bool? canViewProfile,
    bool? isLive,
    String? liveId,
    String? liveStatus,
    String? liveTitle,
    String? liveCoverImage,
    String? liveStartedAt,
    int? liveViewerCount,
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
      isDeleted: isDeleted ?? this.isDeleted,
      businessCategory: businessCategory ?? this.businessCategory,
      sellerType: sellerType ?? this.sellerType,
      shopBanner: shopBanner ?? this.shopBanner,
      shopBannerMediaId: shopBannerMediaId ?? this.shopBannerMediaId,
      aboutBusiness: aboutBusiness ?? this.aboutBusiness,
      businessAddress: businessAddress ?? this.businessAddress,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      ratingDisplay: ratingDisplay ?? this.ratingDisplay,
      totalReviews: totalReviews ?? this.totalReviews,
      totalReviewsDisplay: totalReviewsDisplay ?? this.totalReviewsDisplay,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalFollowersDisplay:
          totalFollowersDisplay ?? this.totalFollowersDisplay,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      totalFollowingDisplay:
          totalFollowingDisplay ?? this.totalFollowingDisplay,
      totalFriends: totalFriends ?? this.totalFriends,
      totalFriendsDisplay: totalFriendsDisplay ?? this.totalFriendsDisplay,
      totalAds: totalAds ?? this.totalAds,
      totalAdsDisplay: totalAdsDisplay ?? this.totalAdsDisplay,
      joined: joined ?? this.joined,
      canEdit: canEdit ?? this.canEdit,
      targetUser: targetUser ?? this.targetUser,
      isSelf: isSelf ?? this.isSelf,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isFriend: isFriend ?? this.isFriend,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      actionLabel: actionLabel ?? this.actionLabel,
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      hasBlockedMe: hasBlockedMe ?? this.hasBlockedMe,
      isBlocked: isBlocked ?? this.isBlocked,
      blockStatus: blockStatus ?? this.blockStatus,
      canFollow: canFollow ?? this.canFollow,
      canMessage: canMessage ?? this.canMessage,
      canCall: canCall ?? this.canCall,
      canViewProfile: canViewProfile ?? this.canViewProfile,
      isLive: isLive ?? this.isLive,
      liveId: liveId ?? this.liveId,
      liveStatus: liveStatus ?? this.liveStatus,
      liveTitle: liveTitle ?? this.liveTitle,
      liveCoverImage: liveCoverImage ?? this.liveCoverImage,
      liveStartedAt: liveStartedAt ?? this.liveStartedAt,
      liveViewerCount: liveViewerCount ?? this.liveViewerCount,
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
  bool get hasLocation => location?.hasLocation ?? false;
  bool get hasOperatingHours => operatingHours.isNotEmpty;
  bool get hasActiveLive => isLive && (liveId?.trim().isNotEmpty ?? false);

  String get effectiveUserId {
    final values = [targetUser, user, seller];
    for (final value in values) {
      final clean = value.trim();
      if (clean.isNotEmpty) return clean;
    }
    return seller;
  }

  String get ratingLabel {
    final value = ratingDisplay?.trim();
    if (value != null && value.isNotEmpty) return value;
    if (rating <= 0) return '—';
    return rating.toStringAsFixed(1);
  }

  String get followersLabel =>
      _displayCount(totalFollowersDisplay, totalFollowers);
  String get followingLabel =>
      _displayCount(totalFollowingDisplay, totalFollowing);
  String get friendsLabel => _displayCount(totalFriendsDisplay, totalFriends);
  String get adsLabel => _displayCount(totalAdsDisplay, totalAds);
  String get reviewsLabel => _displayCount(totalReviewsDisplay, totalReviews);
}

class AOSSellerLocation {
  const AOSSellerLocation({
    required this.hasLocation,
    this.name,
    this.latitude,
    this.longitude,
    this.displayAddress,
    this.locality,
    this.region,
    this.countryCode,
    this.instructions,
    this.updatedAt,
  });

  final bool hasLocation;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? displayAddress;
  final String? locality;
  final String? region;
  final String? countryCode;
  final String? instructions;
  final String? updatedAt;

  factory AOSSellerLocation.fromJson(Map<String, dynamic> json) {
    return AOSSellerLocation(
      hasLocation: parseBool(json['has_location']),
      name: _nullableText(json['name']),
      latitude: asNullableDouble(json['latitude']),
      longitude: asNullableDouble(json['longitude']),
      displayAddress: _nullableText(json['display_address']),
      locality: _nullableText(json['locality']),
      region: _nullableText(json['region']),
      countryCode: _nullableText(json['country_code']),
      instructions: _nullableText(json['instructions']),
      updatedAt: _nullableText(json['updated_at']),
    );
  }

  static AOSSellerLocation? fromJsonOrNull(Object? value) {
    final map = asJsonMap(value);
    if (map.isEmpty) return null;

    final location = AOSSellerLocation.fromJson(map);
    if (!location.hasLocation) return null;

    final hasCoordinates =
        location.latitude != null && location.longitude != null;
    final hasAddress = location.displayAddress?.trim().isNotEmpty ?? false;
    return hasCoordinates || hasAddress ? location : null;
  }

  String get title {
    final value = name?.trim();
    if (value != null && value.isNotEmpty) return value;

    final localityValue = locality?.trim();
    if (localityValue != null && localityValue.isNotEmpty) return localityValue;

    final regionValue = region?.trim();
    if (regionValue != null && regionValue.isNotEmpty) return regionValue;

    return 'Store location';
  }

  String? get subtitle {
    final value = displayAddress?.trim();
    if (value != null && value.isNotEmpty) return value;

    final parts = [locality, region, countryCode]
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}

bool parseBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is int) return v == 1;

  if (v is String) {
    final value = v.trim().toLowerCase();
    if (value == '1' || value == 'true' || value == 'yes') return true;
    if (value == '0' || value == 'false' || value == 'no') return false;
  }

  return fallback;
}

String _displayCount(String? display, int value) {
  final clean = display?.trim();
  if (clean != null && clean.isNotEmpty) return clean;
  return _formatCount(value);
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toString();
}

String? _nullableText(Object? value) {
  final clean = value?.toString().trim();
  if (clean == null || clean.isEmpty || clean == 'null') return null;
  return clean;
}
