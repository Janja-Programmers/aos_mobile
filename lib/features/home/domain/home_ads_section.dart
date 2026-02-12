import 'package:flutter/foundation.dart';

/// Declarative config for a Home ads "rail" (section).
///
/// Each section can be backed by a category (resolved from the catalog tree)
/// and/or a supported backend sort.
@immutable
class HomeAdsSection {
  const HomeAdsSection({
    required this.key,
    required this.title,
    this.preferredCategoryNames = const <String>[],
    this.sort,
    this.limit = 8,
  });

  /// Stable identifier for caching providers.
  final String key;

  /// Section header shown in the UI.
  final String title;

  /// Category names to try match against the catalog tree (case-insensitive).
  ///
  /// First match wins.
  final List<String> preferredCategoryNames;

  /// Backend sort (see list_ads.py: recent, price_low, price_high).
  final String? sort;

  /// Max number of items to fetch.
  final int limit;
}
