class WishlistState {
  WishlistState({
    Map<String, bool> overrides = const <String, bool>{},
    Set<String> pending = const <String>{},
  }) : overrides = Map<String, bool>.unmodifiable(overrides),
       pending = Set<String>.unmodifiable(pending);

  final Map<String, bool> overrides;
  final Set<String> pending;

  factory WishlistState.initial() => WishlistState();

  bool resolve(String adId, {required bool fallback}) {
    final id = adId.trim();
    if (id.isEmpty) return fallback;
    return overrides[id] ?? fallback;
  }

  WishlistState copyWith({Map<String, bool>? overrides, Set<String>? pending}) {
    return WishlistState(
      overrides: overrides ?? this.overrides,
      pending: pending ?? this.pending,
    );
  }
}
