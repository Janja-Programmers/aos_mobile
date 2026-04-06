import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/seller/seller_verification/controllers/seller_status_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_form_state.dart';
import 'package:africaonlinestores/features/seller/seller_verification/utils/verification_steps_builder.dart';

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
                      final isValid = currentStep.validator(state.data);

                      if (!isValid) {
                        ShowSnack(
                          context,
                          "Please complete required fields",
                        ).error();
                        return;
                      }

                      if (isLast) {
                        controller.submit((payload) async {
                          final res = await _resolveCall(
                            api,
                            payload,
                            state.mode,
                          );

                          res.fold(
                            (failure) {
                              ShowSnack(context, failure.message).error();
                            },
                            (_) {
                              ShowSnack(
                                context,
                                state.mode == VerificationMode.update
                                    ? "Verification updated"
                                    : "Verification submitted",
                              ).success();

                              ref.invalidate(sellerStatusProvider);

                              Future.delayed(
                                const Duration(milliseconds: 400),
                                () {
                                  if (context.mounted) Navigator.pop(context);
                                },
                              );
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
        ],
      ),
    ),
  );
}

Future<Either<Failure, Map<String, dynamic>>> _resolveCall(
  dynamic api,
  Map<String, dynamic> payload,
  VerificationMode mode,
) {
  return mode == VerificationMode.update
      ? api.updateMySeller(payload: payload)
      : api.submitVerification(payload: payload);
}
