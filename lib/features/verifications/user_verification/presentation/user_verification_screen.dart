import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_type.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/identity_document_step.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/personal_details_step.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/selfie_verification_step.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_review_step.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/widgets/selfie_source_bottom_sheet.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/widgets/user_verification_stepper.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/widgets/user_verification_submission_dialog.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UserVerificationScreen extends ConsumerStatefulWidget {
  const UserVerificationScreen({
    super.key,
    this.verificationType = VerificationType.individual,
  });

  final VerificationType verificationType;

  @override
  ConsumerState<UserVerificationScreen> createState() =>
      _UserVerificationScreenState();
}

class _UserVerificationScreenState
    extends ConsumerState<UserVerificationScreen> {
  final PageController _pageController = PageController();

  bool _allowPop = false;
  bool _isExiting = false;
  bool _isPreparingFront = false;
  bool _isPreparingBack = false;
  bool _isPreparingSelfie = false;

  bool get _isPreparingImage =>
      _isPreparingFront || _isPreparingBack || _isPreparingSelfie;

  @override
  void initState() {
    super.initState();
    ref
        .read(userVerificationControllerProvider.notifier)
        .setVerificationType(widget.verificationType);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restoreLocalDraft());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _restoreLocalDraft() async {
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final restored = await controller.restoreLocalDraft();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final step = ref.read(userVerificationControllerProvider).currentStep;
      _pageController.jumpToPage(step);
    });

    if (restored) {
      ShowSnack(context, 'Your verification draft was restored.').success();
    }
  }

  Future<void> _goTo(int index) async {
    final verificationState = ref.read(userVerificationControllerProvider);
    if (_isPreparingImage || verificationState.isBusy) return;

    final controller = ref.read(userVerificationControllerProvider.notifier);
    final target = index.clamp(0, 3).toInt();

    if (!controller.isStepAccessible(target)) {
      ShowSnack(context, 'Complete the previous step first.').error();
      return;
    }

    final moved = controller.goToStep(target);
    if (!moved || !_pageController.hasClients) return;

    await _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _next() async {
    final state = ref.read(userVerificationControllerProvider);
    if (_isPreparingImage || state.isBusy) return;
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final step = state.currentStep;
    final missing = controller.missingForStep(step);

    if (missing != null) {
      ShowSnack(context, missing).error();
      return;
    }

    if (step == 3) {
      final result = await controller.submit();
      if (!mounted) return;

      final failure = result.leftOrNull;
      if (failure != null) {
        ShowSnack(context, failure.message).error();
        return;
      }

      await _showSubmittedDialog();
      return;
    }

    controller.markCurrentStepComplete();
    await _goTo(step + 1);
  }

  Future<void> _back() async {
    final state = ref.read(userVerificationControllerProvider);
    if (_isPreparingImage || state.isBusy || _isExiting) return;

    if (state.currentStep == 0) {
      await _exitAndSave();
      return;
    }

    final controller = ref.read(userVerificationControllerProvider.notifier);
    final moved = controller.previousStep();
    if (!moved || !_pageController.hasClients) return;

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _exitAndSave() async {
    if (_isExiting) return;

    setState(() => _isExiting = true);

    try {
      await ref
          .read(userVerificationControllerProvider.notifier)
          .saveLocalDraft();
    } on Exception {
      if (mounted) {
        ShowSnack(
          context,
          'Unable to save your verification draft. Please try again.',
        ).error();
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _isExiting = false);
      }
    }

    if (!mounted) return;

    setState(() => _allowPop = true);
    Navigator.pop(context);
  }

  Future<void> _pickAndUploadDocument({required bool front}) async {
    final verificationState = ref.read(userVerificationControllerProvider);
    if (_isPreparingImage || verificationState.isBusy) return;

    var isPreparing = false;

    try {
      final file = await MediaHelper.pickImageWithChoice(context);
      if (!mounted || file == null) return;

      isPreparing = true;
      setState(() {
        if (front) {
          _isPreparingFront = true;
        } else {
          _isPreparingBack = true;
        }
      });
      await WidgetsBinding.instance.endOfFrame;

      final fixed = await normalizeImageOrientation(file);
      if (!mounted) return;

      final result = await ref
          .read(userVerificationControllerProvider.notifier)
          .uploadDocument(file: fixed, front: front);

      if (!mounted) return;

      result.fold(
        (failure) => ShowSnack(context, failure.message).error(),
        (_) => ShowSnack(
          context,
          front ? 'Front ID uploaded.' : 'Back ID uploaded.',
        ).success(),
      );
    } on Exception {
      if (mounted) {
        ShowSnack(context, 'Unable to add this document photo.').error();
      }
    } finally {
      if (mounted && isPreparing) {
        setState(() {
          if (front) {
            _isPreparingFront = false;
          } else {
            _isPreparingBack = false;
          }
        });
      }
    }
  }

  Future<void> _chooseAndUploadSelfie() async {
    final verificationState = ref.read(userVerificationControllerProvider);
    if (_isPreparingImage || verificationState.isBusy) return;

    try {
      final source = await showSelfieSourceBottomSheet(context);
      if (!mounted || source == null) return;

      final File? file = switch (source) {
        SelfieSource.camera => await MediaHelper.pickImageFromCamera(
          preferredCameraDevice: CameraDevice.front,
        ),
        SelfieSource.gallery => await MediaHelper.pickImageFromGallery(),
      };

      if (!mounted || file == null) return;

      setState(() => _isPreparingSelfie = true);
      await WidgetsBinding.instance.endOfFrame;

      final fixed = await normalizeImageOrientation(file);
      if (!mounted) return;

      final result = await ref
          .read(userVerificationControllerProvider.notifier)
          .uploadSelfie(fixed);

      if (!mounted) return;

      result.fold(
        (failure) => ShowSnack(context, failure.message).error(),
        (_) => ShowSnack(context, 'Selfie uploaded.').success(),
      );
    } on Exception {
      if (mounted) {
        ShowSnack(
          context,
          'Unable to open the camera or selected photo.',
        ).error();
      }
    } finally {
      if (mounted && _isPreparingSelfie) {
        setState(() => _isPreparingSelfie = false);
      }
    }
  }

  Future<void> _showSubmittedDialog() async {
    final done = await showUserVerificationSubmissionDialog(context);
    if (!done || !mounted) return;

    ref.read(userVerificationControllerProvider.notifier).reset();
    setState(() => _allowPop = true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final isBusy = state.isBusy || _isPreparingImage;

    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _allowPop) return;
        unawaited(_back());
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colors.surface,
          leading: IconButton(
            tooltip: state.currentStep == 0 ? 'Save and exit' : 'Previous step',
            onPressed: isBusy || _isExiting
                ? null
                : () => unawaited(_back()),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text('Get Verified', style: context.h4),
          actions: [
            IconButton(
              tooltip: 'Save and continue later',
              onPressed: isBusy || _isExiting
                  ? null
                  : () => unawaited(_exitAndSave()),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: state.isRestoringDraft
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  UserVerificationStepper(
                    currentStep: state.currentStep,
                    completedSteps: state.completedSteps,
                    onStepTapped: (step) {
                      if (isBusy) return;
                      unawaited(_goTo(step));
                    },
                    isStepAccessible: controller.isStepAccessible,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const PersonalDetailsStep(),
                        IdentityDocumentStep(
                          onUpload: _pickAndUploadDocument,
                          isPreparingFront: _isPreparingFront,
                          isPreparingBack: _isPreparingBack,
                        ),
                        SelfieVerificationStep(
                          onChooseSelfie: _chooseAndUploadSelfie,
                          isPreparing: _isPreparingSelfie,
                        ),
                        const UserVerificationReviewStep(),
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: state.isRestoringDraft
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Row(
                    children: [
                      if (state.currentStep > 0) ...[
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: isBusy
                                  ? null
                                  : () => unawaited(_back()),
                              child: const Text('Back'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: PrimaryButton(
                          text: state.currentStep == 3
                              ? 'Submit'
                              : 'Continue',
                          loading: state.isSubmitting,
                          onPressed: isBusy
                              ? null
                              : () => unawaited(_next()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
