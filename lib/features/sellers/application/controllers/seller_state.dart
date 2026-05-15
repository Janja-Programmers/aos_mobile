import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';

const Object _unset = Object();

class SellerState {
  const SellerState({
    this.loading = false,
    this.error,
    this.seller,
    this.followingLoading = false,
    this.isFollowing,
    this.updating = false,
  });

  final bool loading;
  final String? error;
  final AOSSellerProfile? seller;
  final bool followingLoading;
  final bool? isFollowing;
  final bool updating;

  SellerState copyWith({
    bool? loading,
    Object? error = _unset,
    AOSSellerProfile? seller,
    bool? followingLoading,
    bool? isFollowing,
    bool? updating,
  }) {
    return SellerState(
      loading: loading ?? this.loading,
      error: error == _unset ? this.error : error as String?,
      seller: seller ?? this.seller,
      followingLoading: followingLoading ?? this.followingLoading,
      isFollowing: isFollowing ?? this.isFollowing,
      updating: updating ?? this.updating,
    );
  }
}
