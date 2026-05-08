import 'package:africaonlinestores/features/sellers/seller_verification/presentation/widgets/verification_submit_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/sellers/seller_verification/controllers/seller_status_provider.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/controllers/verification_form_state.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/utils/verification_steps_builder.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

Widget buildVerificationBottomBar({
  required BuildContext context,
  required WidgetRef ref,
  required SellerVerificationState state,
  required List<VerificationStepDef> steps,
  required dynamic controller,
  required dynamic api,
  required VoidCallback onNext,
  required VoidCallback onBack,
}) {
  final colors = context.appColors;
  final index = state.currentStep;
  final currentStep = steps[index];
  final isLast = index == steps.length - 1;

  final missingFields = controller.missingCurrentStepFields() as List<String>;
  final canContinue =
      missingFields.isEmpty && currentStep.validator(state.data);

  return SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// 🔙 BACK BUTTON
          if (index > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSubmitting ? null : onBack,
                child: const Text("Back"),
              ),
            ),

          if (index > 0) const SizedBox(width: 12),

          /// ➡️ NEXT / SUBMIT
          Expanded(
            child: GestureDetector(
              onTap: state.isSubmitting || canContinue
                  ? null
                  : () => _showMissingFieldsSnack(context, missingFields),
              child: AbsorbPointer(
                absorbing: !canContinue,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          if (!canContinue) {
                            _showMissingFieldsSnack(context, missingFields);
                            return;
                          }

                          if (isLast) {
                            await controller.submit((payload) async {
                              final res = await _resolveCall(
                                api,
                                payload,
                                state.mode,
                              );

                              await res.fold(
                                (failure) async {
                                  ShowSnack(context, failure.message).error();
                                },
                                (_) async {
                                  ref.invalidate(sellerStatusProvider);

                                  if (!context.mounted) return;

                                  final result = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) =>
                                        const VerificationSubmitSuccessDialog(),
                                  );

                                  if (result == true && context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                },
                              );
                            });
                          } else {
                            onNext();
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isLast
                              ? (state.mode == VerificationMode.update
                                    ? "Update"
                                    : "Submit")
                              : "Continue",
                          style: context.body.copyWith(color: colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showMissingFieldsSnack(BuildContext context, List<String> missingFields) {
  if (missingFields.isEmpty) {
    ShowSnack(context, "Please complete required fields").error();
    return;
  }

  ShowSnack(context, "Please fill: ${missingFields.join(', ')}").error();
}

Future<Either<Failure, Map<String, dynamic>>> _resolveCall(
  dynamic api,
  Map<String, dynamic> payload,
  VerificationMode mode,
) {
  return mode == VerificationMode.update
      ? api.submitVerification(payload: payload)
      : api.submitVerification(payload: payload);
}
