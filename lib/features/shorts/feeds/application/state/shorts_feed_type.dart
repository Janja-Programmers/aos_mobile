enum ShortsFeedType { forYou, following, live }

extension ShortsFeedTypeX on ShortsFeedType {
  String get label {
    switch (this) {
      case ShortsFeedType.forYou:
        return 'For You';
      case ShortsFeedType.following:
        return 'Following';
      case ShortsFeedType.live:
        return 'Live';
    }
  }
}
