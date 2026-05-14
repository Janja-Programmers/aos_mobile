import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/verifications/presentation/widgets/verification_bottom_bar.dart';
import 'package:africaonlinestores/features/verifications/utils/verification_flow_helpers.dart';
import 'package:africaonlinestores/features/verifications/utils/verification_steps_builder.dart';
import 'package:africaonlinestores/features/verifications/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/data/verification_api.dart';

import 'package:africaonlinestores/features/verifications/presentation/widgets/seller_verification_shell.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _goTo(int i) async {
    if (!isStepAccessible(i, ref.read(sellerVerificationControllerProvider))) {
      return;
    }

    if (_pageCtrl.page?.round() == i) return;

    final controller = ref.read(sellerVerificationControllerProvider.notifier);

    controller.goToStep(i);

    if (!_pageCtrl.hasClients) return;

    await _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleBack(int index) async {
    final controller = ref.read(sellerVerificationControllerProvider.notifier);

    if (index == 0) {
      if (mounted) Navigator.pop(context);
      return;
    }

    controller.previousStep();

    if (!_pageCtrl.hasClients) return;

    await _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerVerificationControllerProvider);
    final controller = ref.read(sellerVerificationControllerProvider.notifier);
    final api = ref.read(verificationApiProvider);

    final steps = buildVerificationSteps();
    final index = state.currentStep.clamp(0, steps.length - 1);

    return SellerVerificationShell(
      title: "Business Verification",

      currentIndex: index,
      steps: steps.map((e) => e.title).toList(),
      completed: completedSteps(state),

      posting: state.isSubmitting,

      onStepTapped: (i) => _goTo(i),
      isStepAccessible: (i) => isStepAccessible(i, state),

      onBackPressed: () => _handleBack(index),
      onCancelPressed: () => Navigator.pop(context),

      bottom: buildVerificationBottomBar(
        context: context,
        ref: ref,
        state: state,
        steps: steps,
        controller: controller,
        api: api,
        onNext: () => _goTo(index + 1),
        onBack: () => _handleBack(index),
      ),

      child: PageView.builder(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (_, i) => steps[i].builder(context),
      ),
    );
  }
}
