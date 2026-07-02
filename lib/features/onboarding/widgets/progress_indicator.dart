import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 12 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }
}
