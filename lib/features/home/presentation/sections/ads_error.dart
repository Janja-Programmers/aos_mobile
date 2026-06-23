import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AdListErrorView extends StatelessWidget {
  const AdListErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colors.error),
            const SizedBox(height: 16),

            Text('Something went wrong', style: context.h4),
            const SizedBox(height: 8),

            Text(
              message,
              style: context.p.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.white,
                backgroundColor: colors.primary,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
