import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/onboarding/widgets/progress_indicator.dart';
import 'package:africaonlinestores/features/onboarding/steps/country_step.dart';
import 'package:africaonlinestores/features/onboarding/steps/language_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentStep = 0;

  void _next() {
    if (_currentStep == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    await ref.read(appBootstrapProvider.notifier).markOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            OnboardingProgressIndicator(
              currentStep: _currentStep,
              totalSteps: 2,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  LanguageStep(onContinue: _next, onSkip: _complete),
                  CountryStep(
                    onContinue: _next,
                    onSkip: _complete,
                    showBack: true,
                    onBack: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
