import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/validators/validation_result.dart';

class CreateAdStepRunner {
  const CreateAdStepRunner({
    required this.steps,
    required this.index,
    required this.draft,
    required this.schema,
  });

  final List<CreateAdStepDef> steps;
  final int index;
  final AdDraft draft;
  final AdCategorySchema schema;

  bool get isLast => index == steps.length - 1;

  CreateAdStepDef get step => steps[index];

  ValidationResult validate() {
    final validator = step.validator;

    if (validator == null) {
      return ValidationResult.valid();
    }

    return validator(draft, schema);
  }

  bool get isValid => validate().isValid;
}
