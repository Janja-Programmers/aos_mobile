import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/ad_stepper.dart';
import 'package:africaonlinestores/shared/components/app_bottom_bar_surface.dart';
import 'package:flutter/material.dart';

class ScaffoldShell extends StatelessWidget {
  const ScaffoldShell({
    super.key,
    required this.currentIndex,
    required this.completed,
    required this.steps,
    required this.posting,
    required this.child,
    required this.bottom,
    required this.onBackPressed,
    required this.onCancelPressed,
    required this.onStepTapped,
    required this.isStepAccessible,
    this.title = 'Create Ad',
  });

  final int currentIndex;
  final Set<int> completed;
  final List<String> steps;
  final bool posting;
  final Widget child;
  final Widget bottom;

  final VoidCallback onBackPressed;
  final VoidCallback onCancelPressed;

  final void Function(int index) onStepTapped;
  final bool Function(int index) isStepAccessible;

  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: posting ? null : onBackPressed,
          ),
          title: Text(title, style: context.h5),
          actions: [
            IconButton(
              onPressed: posting ? null : onCancelPressed,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Column(
          children: [
            if (steps.length > 1)
              AdStepper(
                steps: steps,
                currentIndex: currentIndex,
                completed: completed,
                onStepTapped: onStepTapped,
                isStepAccessible: isStepAccessible,
              ),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: AppBottomBarSurface(
          padding: const EdgeInsets.all(10),
          child: bottom,
        ),
      ),
    );
  }
}
