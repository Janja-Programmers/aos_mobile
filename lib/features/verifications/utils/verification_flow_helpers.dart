import 'package:africaonlinestores/features/verifications/controllers/verification_form_state.dart';
import 'package:africaonlinestores/features/verifications/utils/verification_steps_builder.dart';

Set<int> completedSteps(SellerVerificationState state) {
  final steps = buildVerificationSteps();

  final completed = <int>{};

  for (int i = 0; i < steps.length; i++) {
    if (steps[i].validator(state.data)) {
      completed.add(i);
    }
  }

  return completed;
}

bool isStepAccessible(int index, SellerVerificationState state) {
  if (index == state.currentStep) return true;

  final steps = buildVerificationSteps();

  if (index < state.currentStep) return true;

  final prevValid = steps[index - 1].validator(state.data);

  return prevValid;
}
