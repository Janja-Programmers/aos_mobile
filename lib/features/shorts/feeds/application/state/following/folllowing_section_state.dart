class FollowingSectionState {
  final bool isLoading;
  final String? error;
  final List<SellerSuggestion> sellers;

  const FollowingSectionState({
    required this.isLoading,
    required this.error,
    required this.sellers,
  });

  factory FollowingSectionState.initial() {
    return const FollowingSectionState(
      isLoading: false,
      error: null,
      sellers: [],
    );
  }

  FollowingSectionState copyWith({
    bool? isLoading,
    String? error,
    List<SellerSuggestion>? sellers,
  }) {
    return FollowingSectionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sellers: sellers ?? this.sellers,
    );
  }
}

class SellerSuggestion {
  final String sellerId;
  final String displayName;
  final String? avatar;
  final int totalFollowers;
  final bool isFollowing;

  const SellerSuggestion({
    required this.sellerId,
    required this.displayName,
    required this.avatar,
    required this.totalFollowers,
    required this.isFollowing,
  });

  factory SellerSuggestion.fromJson(Map<String, dynamic> json) {
    final rawDisplayName = json['display_name']?.toString().trim() ?? '';

    return SellerSuggestion(
      sellerId:
          json['seller']?.toString().trim() ??
          json['seller_id']?.toString().trim() ??
          '',
      displayName: rawDisplayName.isEmpty ? 'AOS User' : rawDisplayName,
      avatar: json['avatar']?.toString(),
      totalFollowers: (json['total_followers'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] == true,
    );
  }

  bool get canBeSuggested => !isFollowing;

  SellerSuggestion copyWith({
    String? sellerId,
    String? displayName,
    String? avatar,
    int? totalFollowers,
    bool? isFollowing,
  }) {
    return SellerSuggestion(
      sellerId: sellerId ?? this.sellerId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  String get initials {
    final clean = displayName.trim();
    if (clean.isEmpty) return '?';

    final parts = clean.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
