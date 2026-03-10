import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

abstract class PricingPolicy {
  List<String> allowedTypes(PricingSchema schema);

  bool requirePrice(AdDraft d, PricingSchema schema);

  bool requireUnit(AdDraft d, PricingSchema schema);

  bool allowOffer(AdDraft d, PricingSchema schema);

  bool requireOfferDates(AdDraft d);

  void normalizeDraft(AdDraft draft, void Function(AdDraft) apply);
}
