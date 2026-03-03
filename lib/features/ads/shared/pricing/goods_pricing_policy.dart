import 'package:africaonlinestores/features/ads/shared/pricing/pricing_policy.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

class GoodsPricingPolicy implements PricingPolicy {
  @override
  List<String> allowedTypes(PricingSchema schema) {
    return const ['Fixed', 'Negotiable'];
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
    return d.offerPrice != null;
  }

  @override
  void normalizeDraft(AdDraft draft, void Function(AdDraft) apply) {
    if (draft.priceType == 'Negotiable') {
      apply(draft.copyWith(offerPrice: null, offerStart: null, offerEnd: null));
    }

    if (draft.priceType == 'Contact for price') {
      apply(draft.copyWith(priceType: 'Fixed'));
    }
  }
}
