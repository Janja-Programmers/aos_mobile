import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class AllAdsParams {
  final String? parentCategoryId;
  final String? initialCategoryId;
  final String? sellerId;
  final DealType dealType;
  final AdsSort? sort;
  final AllAdsMode mode;

  const AllAdsParams({
    this.parentCategoryId,
    this.initialCategoryId,
    this.sellerId,
    this.dealType = DealType.all,
    this.sort,
    this.mode = AllAdsMode.normal,
  });

  @override
  bool operator ==(Object other) {
    return other is AllAdsParams &&
        other.parentCategoryId == parentCategoryId &&
        other.initialCategoryId == initialCategoryId &&
        other.sellerId == sellerId &&
        other.dealType == dealType &&
        other.sort == sort &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(
    parentCategoryId,
    initialCategoryId,
    sellerId,
    dealType,
    sort,
    mode,
  );
}
