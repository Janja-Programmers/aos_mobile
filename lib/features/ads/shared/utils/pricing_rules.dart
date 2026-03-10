import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

String _norm(String? s) => (s ?? '').trim().toLowerCase();

bool isFixed(String? t) => _norm(t) == 'fixed';
bool isNegotiable(String? t) => _norm(t) == 'negotiable';

bool typeNeedsAmount(String? t) => isFixed(t) || isNegotiable(t);
bool typeNeedsUnit(String? t, PricingSchema schema) =>
    typeNeedsAmount(t) && schema.allowedUnits.isNotEmpty;

bool isEmptyStr(String? s) => s == null || s.trim().isEmpty;

bool isValidOffer(double? price, double? offer) {
  if (price == null || offer == null) return true;
  return offer < price;
}
