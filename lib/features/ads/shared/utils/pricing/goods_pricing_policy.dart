import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing/pricing_policy.dart';

class GoodsPricingPolicy implements PricingPolicy {
  @override
  List<String> allowedTypes(PricingSchema schema) {
    return schema.allowedTypes.isEmpty
        ? const ['Fixed', 'Negotiable']
        : schema.allowedTypes;
  }

  @override
  bool requirePrice(AdDraft d, PricingSchema schema) {
    return d.priceType == 'Fixed' || d.priceType == 'Negotiable';
  }

  @override
  bool requireUnit(AdDraft d, PricingSchema schema) {
    return false;
  }

  @override
  bool allowOffer(AdDraft d, PricingSchema schema) {
    return d.priceType == 'Fixed';
  }

  @override
  bool requireOfferDates(AdDraft d) {
    return d.offerPrice != null && d.offerPrice! > 0;
  }

  @override
  void normalizeDraft(AdDraft draft, void Function(AdDraft) apply) {
    if (draft.priceType == 'Negotiable') {
      apply(draft.copyWith());
    }

    if (draft.priceType == 'Contact for price') {
      apply(draft.copyWith());
    }
  }
}
