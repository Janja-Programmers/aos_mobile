import 'package:flutter/foundation.dart';

@immutable
class HomeAdsSection {
  const HomeAdsSection({
    required this.key,
    this.title,
    this.categoryId,
    this.sort,
    this.promotionType,
    this.limit = 8,
  });

  final String key;
  final String? title;
  final String? categoryId;
  final String? sort;
  final String? promotionType;
  final int limit;

  bool get isCategorySection => categoryId?.trim().isNotEmpty ?? false;
}
