import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/basic_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/details_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/description_step.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing_step.dart';

import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_validator.dart';

typedef StepValidator = bool Function(AdDraft draft, AdCategorySchema schema);

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
    final steps = <CreateAdStepDef>[];

    // ---------------- Basic ----------------
    steps.add(
      CreateAdStepDef(
        label: 'Basic',
        widget: const BasicStep(),
        validator: (draft, _) => CreateAdValidator.basic(draft),
      ),
    );

    // ---------------- Details ----------------
    if (schema.attributes.isNotEmpty) {
      steps.add(
        CreateAdStepDef(
          label: 'Details',
          widget: DetailsStep(schema: schema),
          validator: CreateAdValidator.details,
        ),
      );
    }

    // ---------------- Description ----------------
    steps.add(
      const CreateAdStepDef(
        label: 'Description',
        widget: DescriptionStep(),
        // Optional step → no validator
      ),
    );

    // ---------------- Pricing ----------------
    if (schema.pricing.requirement != PricingRequirement.hidden) {
      steps.add(
        CreateAdStepDef(
          label: 'Pricing',
          widget: PricingStep(schema: schema.pricing),
          validator: (d, s) => CreateAdValidator.pricing(d, s.pricing),
        ),
      );
    }

    return steps;
  }
}
