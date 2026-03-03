import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/pricing/pricing_policy.dart';
import 'package:africaonlinestores/features/ads/shared/pricing/goods_pricing_policy.dart';
import 'package:africaonlinestores/features/ads/shared/pricing/service_pricing_policy.dart';

class PricingPolicyResolver {
  static PricingPolicy resolve(PricingSchema schema) {
    if (schema.isService) {
      return ServicePricingPolicy();
    }
    return GoodsPricingPolicy();
  }
}
