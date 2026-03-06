import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/onboarding/steps/welcome_step.dart';
import 'package:africaonlinestores/features/onboarding/steps/language_step.dart';
import 'package:africaonlinestores/features/onboarding/steps/country_step.dart';
import 'package:africaonlinestores/features/onboarding/steps/currency_step.dart';
import 'package:africaonlinestores/features/onboarding/widgets/progress_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      ref
          .read(onboardingControllerProvider.notifier)
          .initializeDefaultsIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final steps = <Widget>[
      WelcomeStep(onContinue: controller.nextStep),

      LanguageStep(onContinue: controller.nextStep),

      CountryStep(
        onContinue: controller.nextStep,
        onBack: controller.previousStep,
        onSkip: controller.finish,
        showBack: true,
      ),

      CurrencyStep(
        onContinue: controller.finish,
        onBack: controller.previousStep,
        onSkip: controller.finish,
        showBack: true,
      ),
    ];

    final safeIndex = state.step.clamp(0, steps.length - 1);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            OnboardingProgressIndicator(
              currentStep: safeIndex,
              totalSteps: steps.length,
            ),

            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey<int>(safeIndex),
                  child: steps[safeIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
