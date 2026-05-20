class ShortContentModes {
  const ShortContentModes._();

  static const String shop = 'shop';
  static const String geo = 'geo';
  static const String vibes = 'vibes';
  static const String learn = 'learn';

  static const Set<String> validModes = {shop, geo, vibes, learn};

  static const Set<String> modesRequiringAd = {shop};

  static bool isValid(String mode) {
    return validModes.contains(mode.trim().toLowerCase());
  }

  static bool requiresAd(String mode) {
    return modesRequiringAd.contains(mode.trim().toLowerCase());
  }

  static String normalize(String? mode) {
    if (mode == null || mode.trim().isEmpty) {
      return shop;
    }

    final normalized = mode.trim().toLowerCase();

    if (!isValid(normalized)) {
      return shop;
    }

    return normalized;
  }
}
