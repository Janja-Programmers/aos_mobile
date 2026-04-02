import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/seller/seller_verification/presentation/widgets/verification_stepper.dart';

class SellerVerificationShell extends StatelessWidget {
  const SellerVerificationShell({
    super.key,
    required this.title,
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
  });

  final String title;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: posting ? null : onBackPressed,
        ),
        title: Text(title),
        actions: [
          IconButton(
            onPressed: posting ? null : onCancelPressed,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          /// ✅ Use your NEW stepper here
          VerificationStepper(
            totalSteps: steps.length,
            currentIndex: currentIndex,
            completed: completed,
            onStepTapped: onStepTapped,
            isStepAccessible: isStepAccessible,
          ),

          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: bottom,
    );
  }
}
