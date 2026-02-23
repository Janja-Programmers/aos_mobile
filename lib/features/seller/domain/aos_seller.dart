class AOSSellerProfile {
  const AOSSellerProfile({
    required this.shopName,
    required this.avatar,
    required this.shopBanner,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalAds,
    required this.joined,
    required this.isFollowing,
  });

  final String shopName;
  final String avatar;
  final String? shopBanner;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalAds;
  final String joined;
  final bool isFollowing;

  factory AOSSellerProfile.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    return AOSSellerProfile(
      shopName: (json['shop_name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      shopBanner: (json['shop_banner'] ?? '').toString().trim().isEmpty
          ? null
          : json['shop_banner'].toString(),
      rating: parseDouble(json['rating']),
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
      totalFollowers:
          int.tryParse((json['total_followers'] ?? 0).toString()) ?? 0,
      totalAds: int.tryParse((json['total_ads'] ?? 0).toString()) ?? 0,
      joined: (json['joined'] ?? '').toString(),
      isFollowing: json['is_following'] == true,
    );
  }
}
