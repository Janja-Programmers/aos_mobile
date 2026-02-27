import 'package:flutter/foundation.dart';

@immutable
class HomeAdsSection {
  const HomeAdsSection({
    required this.key,
    required this.title,
    this.preferredCategoryNames = const <String>[],
    this.sort,
    this.promotionType,
    this.limit = 8,
    this.seeAllCategoryId,
  });

  final String key;
  final String title;
  final List<String> preferredCategoryNames;
  final String? sort;
  final String? promotionType;
  final int limit;
  final String? seeAllCategoryId;
}
