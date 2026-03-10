import 'package:africaonlinestores/features/ads/ads_create/ui/steps/validators/validation_result.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/shared/utils/pricing/pricing_policy_resolver.dart';
import 'package:africaonlinestores/features/ads/shared/utils/enums.dart';

class CreateAdValidator {
  // ---------------- BASIC ----------------

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

  // ---------------- DETAILS ----------------

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

  // ---------------- DESCRIPTION ----------------

  static ValidationResult description(AdDraft d) {
    final errors = <String, String>{};

    final text = d.description.trim();

    if (text.isEmpty) {
      errors['description'] = 'Description is required';
    } else if (text.length < 20) {
      errors['description'] = 'Description must be at least 20 characters';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  // ---------------- PRICING ----------------

  static ValidationResult pricing(AdDraft d, AdCategorySchema schema) {
    final errors = <String, String>{};

    final pricing = schema.pricing;

    // Skip validation if pricing hidden
    if (pricing.requirement == PricingRequirement.hidden) {
      return ValidationResult.valid();
    }

    // Resolve policy using full schema
    final policy = PricingPolicyResolver.resolve(schema);

    final allowed = policy.allowedTypes(pricing);

    // Validate price type
    if (d.priceType == null || !allowed.contains(d.priceType)) {
      errors['priceType'] = 'Select a valid price type';
    }

    // Validate price
    if (policy.requirePrice(d, pricing)) {
      if (d.price == null || d.price! <= 0) {
        errors['price'] = 'Enter a valid price';
      }
    }

    // Validate unit
    if (policy.requireUnit(d, pricing)) {
      if (d.priceUnit == null || d.priceUnit!.trim().isEmpty) {
        errors['priceUnit'] = 'Select a price unit';
      }
    }

    // Validate offer allowed
    if (!policy.allowOffer(d, pricing)) {
      if (d.offerPrice != null) {
        errors['offerPrice'] = 'Offer not allowed for this price type';
      }
    }

    // Validate offer price logic
    if (d.offerPrice != null) {
      if (d.offerPrice! <= 0) {
        errors['offerPrice'] = 'Enter a valid offer price';
      }

      if (d.price != null && d.offerPrice! >= d.price!) {
        errors['offerPrice'] = 'Offer price must be lower than price';
      }
    }

    // Validate offer dates
    if (policy.requireOfferDates(d)) {
      if (d.offerStart == null) {
        errors['offerStart'] = 'Select offer start date';
      }

      if (d.offerEnd == null) {
        errors['offerEnd'] = 'Select offer end date';
      }

      if (d.offerStart != null &&
          d.offerEnd != null &&
          d.offerEnd!.isBefore(d.offerStart!)) {
        errors['offerEnd'] = 'End date must be after start date';
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }
}
