import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/validators/validation_result.dart';

class AdFormStepRunner {
  const AdFormStepRunner({
    required this.steps,
    required this.index,
    required this.draft,
    required this.schema,
  });

  final List<CreateAdStepDef> steps;
  final int index;
  final AdDraft draft;
  final AdCategorySchema schema;

  /// True when the current step is the last step
  bool get isLast => steps.isNotEmpty && index == steps.length - 1;

  /// Safely returns the current step
  CreateAdStepDef get step {
    final safeIndex = index.clamp(0, steps.length - 1);
    return steps[safeIndex];
  }

  /// Run validation for current step
  ValidationResult validate() {
    final validator = step.validator;

    if (validator == null) {
      return ValidationResult.valid();
    }

    return validator(draft, schema);
  }

  /// Whether current step is valid
  bool get isValid => validate().isValid;
}
