import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/basic_step.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/details_step.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/description_step.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing_step.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/validators/validation_result.dart';

import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_validator.dart';

typedef StepValidator =
    ValidationResult Function(AdDraft draft, AdCategorySchema schema);

class CreateAdStepDef {
  const CreateAdStepDef({
    required this.label,
    required this.widget,
    this.validator,
  });

  final String label;
  final Widget widget;
  final StepValidator? validator;
}

class AdFormStepsBuilder {
  const AdFormStepsBuilder._();

  static List<CreateAdStepDef> build({required AdCategorySchema schema}) {
    return [
      // ---------------- Basic ----------------
      const CreateAdStepDef(
        label: 'Basic',
        widget: BasicStep(),
        validator: _validateBasic,
      ),

      // ---------------- Details ----------------
      CreateAdStepDef(
        label: 'Details',
        widget: DetailsStep(schema: schema),
        validator: _validateDetails,
      ),

      // ---------------- Description ----------------
      const CreateAdStepDef(
        label: 'Description',
        widget: DescriptionStep(),
        validator: _validateDescription,
      ),

      // ---------------- Pricing ----------------
      CreateAdStepDef(
        label: 'Pricing',
        widget: PricingStep(schema: schema),
        validator: _validatePricing,
      ),
    ];
  }

  // ---------------- Validators ----------------

  static ValidationResult _validateBasic(AdDraft draft, AdCategorySchema _) {
    return AdFormValidator.basic(draft);
  }

  static ValidationResult _validateDetails(
    AdDraft draft,
    AdCategorySchema schema,
  ) {
    if (schema.attributes.isEmpty) {
      return ValidationResult.valid();
    }

    return AdFormValidator.details(draft, schema);
  }

  static ValidationResult _validateDescription(
    AdDraft draft,
    AdCategorySchema _,
  ) {
    return AdFormValidator.description(draft);
  }

  static ValidationResult _validatePricing(
    AdDraft draft,
    AdCategorySchema schema,
  ) {
    return AdFormValidator.pricing(draft, schema);
  }
}
