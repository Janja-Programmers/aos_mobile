class AOSSellerProfile {
  const AOSSellerProfile({
    required this.shopName,
    required this.avatar,
    required this.shopBanner,
    required this.aboutShop,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalAds,
    required this.joined,
    required this.isFollowing,
    required this.isVerified,
  });

  final String shopName;
  final String avatar;
  final String? shopBanner;
  final String? aboutShop;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalAds;
  final String joined;
  final bool isFollowing;
  final bool isVerified;

  /// ✅ SAFE PARSING
  factory AOSSellerProfile.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    String? normalizeNullable(dynamic v) {
      final str = (v ?? '').toString().trim();
      return str.isEmpty ? null : str;
    }

    return AOSSellerProfile(
      shopName: (json['shop_name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      shopBanner: normalizeNullable(json['shop_banner']),
      aboutShop: normalizeNullable(json['about_shop']),
      rating: parseDouble(json['rating']),
      totalReviews: parseInt(json['total_reviews']),
      totalFollowers: parseInt(json['total_followers']),
      totalAds: parseInt(json['total_ads']),
      joined: (json['joined'] ?? '').toString(),
      isFollowing: parseBool(json['is_following']),
      isVerified: parseBool(json['is_verified']),
    );
  }

  /// ✅ FULLY FLEXIBLE COPY
  AOSSellerProfile copyWith({
    String? shopName,
    String? aboutShop,
    String? avatar,
    String? shopBanner,
    double? rating,
    int? totalReviews,
    int? totalFollowers,
    int? totalAds,
    String? joined,
    bool? isFollowing,
    bool? isVerified,
  }) {
    return AOSSellerProfile(
      shopName: shopName ?? this.shopName,
      avatar: avatar ?? this.avatar,
      shopBanner: shopBanner ?? this.shopBanner,
      aboutShop: aboutShop ?? this.aboutShop,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalAds: totalAds ?? this.totalAds,
      joined: joined ?? this.joined,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// HELPER Functions
  bool get hasBanner => shopBanner != null;
  bool get hasDescription => aboutShop != null;
}

/// ✅ KEEP THIS (GOOD)
bool parseBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}
