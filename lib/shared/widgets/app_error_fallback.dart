import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class AppErrorFallback extends StatelessWidget {
  const AppErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.error, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 42, color: colors.error),
              const SizedBox(height: 12),

              Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: context.body,
              ),
              const SizedBox(height: 6),

              Text(
                'Try again later',
                textAlign: TextAlign.center,
                style: context.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
