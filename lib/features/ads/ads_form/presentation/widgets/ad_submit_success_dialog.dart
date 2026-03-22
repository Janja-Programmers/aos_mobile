import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class AdSubmitSuccessDialog extends StatelessWidget {
  const AdSubmitSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: colors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_outlined,
                color: colors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Ad Submitted for Review!',
              textAlign: TextAlign.start,
              style: context.bodyStrong.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),

            Text(
              'We’ll review your ad and notify you once it’s approved or if any changes are needed.',
              textAlign: TextAlign.center,
              style: context.body.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
