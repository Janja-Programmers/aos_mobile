import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

Future<bool> showUserVerificationSubmissionDialog(BuildContext context) async {
  final colors = context.appColors;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: colors.elevated,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: colors.amber.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_bottom_rounded,
                  color: colors.amber,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              Text('Submitted for Review', style: context.h4),
              const SizedBox(height: 12),
              Text(
                "We're reviewing your documents. Once approved, a blue badge appears next to your name.",
                textAlign: TextAlign.center,
                style: context.pMuted.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(dialogContext, true),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
