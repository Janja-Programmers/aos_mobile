import 'package:africaonlinestores/features/ads/ads_create/ui/steps/validators/validation_result.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/pricing/pricing_policy_resolver.dart';

class CreateAdValidator {
  static ValidationResult basic(AdDraft d) {
    final errors = <String, String>{};

    if (d.title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }

    if ((d.locationId ?? '').trim().isEmpty) {
      errors['location'] = 'Location is required';
    }

    if ((d.categoryId ?? '').trim().isEmpty) {
      errors['category'] = 'Category is required';
    }

    if (d.images.isEmpty) {
      errors['images'] = 'At least one image is required';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  static ValidationResult details(AdDraft d, AdCategorySchema schema) {
    final errors = <String, String>{};

    for (final a in schema.attributes) {
      if (!a.required) continue;

      final v = d.attributes[a.key];

      if (v == null) {
        errors[a.key] = '${a.label} is required';
        continue;
      }

      if (v is String && v.trim().isEmpty) {
        errors[a.key] = '${a.label} is required';
      }

      if (v is List && v.isEmpty) {
        errors[a.key] = '${a.label} is required';
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  static ValidationResult description(AdDraft d) {
    final errors = <String, String>{};

    if (d.description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    }

    if (d.description.trim().length < 20) {
      errors['description'] = 'Description must be at least 20 characters';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  static ValidationResult pricing(AdDraft d, PricingSchema schema) {
    final errors = <String, String>{};

    final policy = PricingPolicyResolver.resolve(schema);

    if (schema.requirement == PricingRequirement.hidden) {
      return ValidationResult.valid();
    }

    final allowed = policy.allowedTypes(schema);

    if (d.priceType == null || !allowed.contains(d.priceType)) {
      errors['priceType'] = 'Select a valid price type';
    }

    if (policy.requirePrice(d, schema)) {
      if (d.price == null || d.price! <= 0) {
        errors['price'] = 'Enter a valid price';
      }
    }

    if (policy.requireUnit(d, schema)) {
      if (d.priceUnit == null || d.priceUnit!.trim().isEmpty) {
        errors['priceUnit'] = 'Select a price unit';
      }
    }

    if (!policy.allowOffer(d, schema)) {
      if (d.offerPrice != null) {
        errors['offerPrice'] = 'Offer not allowed for this price type';
      }
    }

    if (policy.requireOfferDates(d)) {
      if (d.offerStart == null) {
        errors['offerStart'] = 'Select offer start date';
      }
      if (d.offerEnd == null) {
        errors['offerEnd'] = 'Select offer end date';
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }
}
