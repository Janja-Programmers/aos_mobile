import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

class AllAdsParams {
  final String? parentCategoryId;
  final String? initialCategoryId;
  final DealType dealType;
  final AdsSort? sort;
  final AllAdsMode mode;

  const AllAdsParams({
    this.parentCategoryId,
    this.initialCategoryId,
    this.dealType = DealType.all,
    this.sort,
    this.mode = AllAdsMode.normal,
  });

  @override
  bool operator ==(Object other) {
    return other is AllAdsParams &&
        other.parentCategoryId == parentCategoryId &&
        other.initialCategoryId == initialCategoryId &&
        other.dealType == dealType &&
        other.sort == sort &&
        other.mode == mode;
  }

  @override
  int get hashCode =>
      Object.hash(parentCategoryId, initialCategoryId, dealType, sort, mode);
}
