import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/utils/pricing_rules.dart';

class CreateAdValidator {
  static bool basic(AdDraft d) {
    return d.title.trim().isNotEmpty &&
        (d.locationId ?? '').trim().isNotEmpty &&
        (d.categoryId ?? '').trim().isNotEmpty &&
        d.images.isNotEmpty;
  }

  static bool details(AdDraft d, AdCategorySchema schema) {
    for (final a in schema.attributes) {
      if (!a.required) continue;
      final v = d.attributes[a.key];
      if (v == null) return false;
      if (v is String && v.trim().isEmpty) return false;
      if (v is List && v.isEmpty) return false;
    }
    return true;
  }

  static bool pricing(AdDraft d, PricingSchema schema) {
    if (schema.requirement == PricingRequirement.hidden) return true;

    final priceType = d.priceType;

    if (schema.requirement == PricingRequirement.optional &&
        isEmptyStr(priceType)) {
      return true;
    }

    if (schema.requirement == PricingRequirement.required &&
        isEmptyStr(priceType)) {
      return false;
    }

    if (typeNeedsAmount(priceType)) {
      if (d.price == null || d.price! <= 0) return false;

      if (typeNeedsUnit(priceType, schema)) {
        if (isEmptyStr(d.priceUnit)) return false;
      }
    }

    return true;
  }
}
