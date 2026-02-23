class WishlistState {
  const WishlistState({
    required this.ids,
    required this.pending,
    required this.isReady,
  });

  final Set<String> ids;
  final Set<String> pending;
  final bool isReady;

  factory WishlistState.initial() =>
      const WishlistState(ids: <String>{}, pending: <String>{}, isReady: false);

  WishlistState copyWith({
    Set<String>? ids,
    Set<String>? pending,
    bool? isReady,
  }) {
    return WishlistState(
      ids: ids ?? this.ids,
      pending: pending ?? this.pending,
      isReady: isReady ?? this.isReady,
    );
  }
}
