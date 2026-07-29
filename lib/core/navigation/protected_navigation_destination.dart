enum ProtectedNavigationKind {
  messages,
  calls,
  profile,
  adDetails,
  account,
  sellerVerification,
  live,
  shortDetails,
  notifications,
  feeds,
  myAds,
}

class ProtectedNavigationDestination {
  const ProtectedNavigationDestination({
    required this.kind,
    this.canonicalId,
    this.otherUser,
    this.displayName,
    this.avatarUrl,
  });

  final ProtectedNavigationKind kind;
  final String? canonicalId;
  final String? otherUser;
  final String? displayName;
  final String? avatarUrl;

  String get signature {
    return <String?>[
      kind.name,
      canonicalId,
      otherUser,
    ].whereType<String>().join('|');
  }
}
