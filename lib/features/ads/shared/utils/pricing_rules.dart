import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

String _norm(String? s) => (s ?? '').trim().toLowerCase();

bool isFixed(String? t) => _norm(t) == 'fixed';
bool isNegotiable(String? t) => _norm(t) == 'negotiable';
bool isContactForPrice(String? t) => _norm(t).startsWith('contact');
bool isFree(String? t) => _norm(t).startsWith('free');

bool typeNeedsAmount(String? t) => isFixed(t) || isNegotiable(t);
bool typeForbidsAmountAndUnit(String? t) => isFree(t) || isContactForPrice(t);

/// Backend-aligned signal: if backend returns allowedUnits -> service category.
/// (Your backend has explicit is_service, but on Flutter you currently infer it via allowedUnits)
bool typeNeedsUnit(String? t, PricingSchema schema) =>
    typeNeedsAmount(t) && schema.allowedUnits.isNotEmpty;

bool isEmptyStr(String? s) => s == null || s.trim().isEmpty;

/// Read backend price from the pricing map.
/// Backend fieldname is `price` (Float).
double? readBackendPrice(Map<String, dynamic> pricing) {
  final raw = pricing['price'];
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString().trim());
}

bool isValidOffer(double? price, double? offer) {
  if (price == null || offer == null) return true;
  return offer < price;
}
