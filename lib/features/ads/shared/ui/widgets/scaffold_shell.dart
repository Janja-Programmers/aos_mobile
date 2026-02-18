import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/ad_stepper.dart';

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
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: posting ? null : onBackPressed,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: posting ? null : onCancelPressed,
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: bottom,
    );
  }
}
