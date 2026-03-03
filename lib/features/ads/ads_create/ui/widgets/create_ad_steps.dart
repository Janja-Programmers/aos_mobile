import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/basic_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/details_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/description_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/validators/validation_result.dart';

import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_validator.dart';

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

class CreateAdStepsBuilder {
  static List<CreateAdStepDef> build({required AdCategorySchema schema}) {
    return [
      // ---------------- Basic ----------------
      CreateAdStepDef(
        label: 'Basic',
        widget: const BasicStep(),
        validator: (draft, _) => CreateAdValidator.basic(draft),
      ),

      // ---------------- Details ----------------
      CreateAdStepDef(
        label: 'Details',
        widget: DetailsStep(schema: schema),
        validator: (draft, s) {
          // If no attributes required → auto valid
          if (s.attributes.isEmpty) {
            return ValidationResult.valid();
          }

          return CreateAdValidator.details(draft, s);
        },
      ),

      // ---------------- Description ----------------
      CreateAdStepDef(
        label: 'Description',
        widget: const DescriptionStep(),
        validator: (draft, _) => CreateAdValidator.description(draft),
      ),

      // ---------------- Pricing ----------------
      CreateAdStepDef(
        label: 'Pricing',
        widget: PricingStep(schema: schema.pricing),
        validator: (draft, s) {
          return CreateAdValidator.pricing(draft, s.pricing);
        },
      ),
    ];
  }
}
