import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing/goods_pricing_policy.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing/pricing_policy.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing/service_pricing_policy.dart';

class PricingPolicyResolver {
  static PricingPolicy resolve(AdCategorySchema schema) {
    if (schema.category.isService) {
      return ServicePricingPolicy();
    }
    return GoodsPricingPolicy();
  }
}
