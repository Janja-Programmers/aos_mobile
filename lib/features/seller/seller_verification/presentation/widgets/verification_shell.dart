import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_form_state.dart';
import 'package:africaonlinestores/features/seller/seller_verification/data/verification_api.dart';
import 'package:africaonlinestores/features/seller/seller_verification/utils/verification_steps_builder.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class SellerVerificationShell extends ConsumerWidget {
  const SellerVerificationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerVerificationControllerProvider);
    final controller = ref.read(sellerVerificationControllerProvider.notifier);
    final api = ref.read(verificationApiProvider);

    final steps = buildVerificationSteps();
    final currentStep = steps[state.currentStep];

    return Scaffold(
      appBar: AppBar(title: Text(currentStep.title)),
      body: Column(
        children: [
          // --- Step Indicator ---
          _StepIndicator(currentIndex: state.currentStep, total: steps.length),

          // --- Step Content ---
          Expanded(child: currentStep.builder(context)),

          // --- Navigation ---
          _NavigationBar(
            state: state,
            steps: steps,
            onNext: () {
              final isValid = currentStep.validator(state.data);

              if (!isValid) {
                ShowSnack(context, "Please complete required fields").error();
                return;
              }

              if (state.currentStep == steps.length - 1) {
                controller.submit((payload) async {
                  final res = await api.submitVerification(payload: payload);
                  res.fold(
                    (failure) {
                      appLogger.e("ERROR: ${failure.message}");
                      ShowSnack(context, failure.message).error();
                    },
                    (data) {
                      ShowSnack(context, "Success: ${data.length}").success();
                      appLogger.i("SUCCESS: $data");
                    },
                  );
                });
              } else {
                controller.nextStep();
              }
            },
            onBack: () {
              if (state.currentStep > 0) {
                controller.previousStep();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentIndex, required this.total});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: List.generate(total, (index) {
          final isActive = index <= currentIndex;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? colors.black : colors.amber,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.state,
    required this.steps,
    required this.onNext,
    required this.onBack,
  });

  final SellerVerificationState state;
  final List<VerificationStepDef> steps;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isLast = state.currentStep == steps.length - 1;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text("Back"),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : onNext,
              child: state.isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(isLast ? "Submit" : "Next"),
            ),
          ),
        ],
      ),
    );
  }
}
