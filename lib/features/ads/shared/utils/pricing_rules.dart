import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

const List<String> defaultAdPriceTypes = <String>[
  'Fixed',
  'Negotiable',
  'Contact for price',
  'Free',
];

String _norm(String? s) => (s ?? '').trim().toLowerCase();

bool isFixed(String? t) => _norm(t) == 'fixed';
bool isNegotiable(String? t) => _norm(t) == 'negotiable';

bool typeNeedsAmount(String? t) => isFixed(t) || isNegotiable(t);
bool typeNeedsUnit(String? t, PricingSchema schema) =>
    typeNeedsAmount(t) && schema.allowedUnits.isNotEmpty;

bool isEmptyStr(String? s) => s == null || s.trim().isEmpty;

List<String> allowedPriceTypesForSchema(PricingSchema schema) {
  return schema.allowedTypes.isEmpty
      ? defaultAdPriceTypes
      : schema.allowedTypes;
}

String? resolvedPriceType(String? selected, PricingSchema schema) {
  final clean = selected?.trim();
  if (clean != null && clean.isNotEmpty) return clean;
  if (schema.requirement == PricingRequirement.hidden) return null;

  // Backend treats an omitted/empty allowed_price_types catalog setting as
  // the global Ads price-type set, which includes Fixed.
  if (allowedPriceTypesForSchema(schema).contains('Fixed')) {
    return 'Fixed';
  }

  return null;
}

bool isValidOffer(double? price, double? offer) {
  if (price == null || offer == null) return true;
  return offer < price;
}
