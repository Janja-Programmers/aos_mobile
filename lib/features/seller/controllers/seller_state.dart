import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';

class SellerState {
  const SellerState({
    this.loading = false,
    this.error,
    this.seller,
    this.followingLoading = false,
    this.isFollowing,
  });

  final bool loading;
  final String? error;
  final AOSSellerProfile? seller;
  final bool followingLoading;
  final bool? isFollowing;

  SellerState copyWith({
    bool? loading,
    String? error,
    AOSSellerProfile? seller,
    bool? followingLoading,
    bool? isFollowing,
  }) {
    return SellerState(
      loading: loading ?? this.loading,
      error: error,
      seller: seller ?? this.seller,
      followingLoading: followingLoading ?? this.followingLoading,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
