import 'dart:io';

import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserVerificationScreen extends ConsumerStatefulWidget {
  const UserVerificationScreen({super.key});

  @override
  ConsumerState<UserVerificationScreen> createState() =>
      _UserVerificationScreenState();
}

class _UserVerificationScreenState
    extends ConsumerState<UserVerificationScreen> {
  final _pageController = PageController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    final clamped = index.clamp(0, 3).toInt();
    ref.read(userVerificationControllerProvider.notifier).goToStep(clamped);
    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        clamped,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _next() async {
    final state = ref.read(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final step = state.currentStep;
    final missing = controller.missingForStep(step);

    if (missing != null) {
      ShowSnack(context, missing).error();
      return;
    }

    if (step == 3) {
      final res = await controller.submit();
      if (!mounted) return;
      res.fold(
        (failure) => ShowSnack(context, failure.message).error(),
        (_) => _showSubmittedDialog(),
      );
      return;
    }

    controller.markCurrentStepComplete();
    await _goTo(step + 1);
  }

  Future<void> _back() async {
    final step = ref.read(userVerificationControllerProvider).currentStep;
    if (step == 0) {
      Navigator.pop(context);
      return;
    }
    await _goTo(step - 1);
  }

  Future<void> _pickAndUploadDocument({required bool front}) async {
    final file = await MediaHelper.pickImageWithChoice(context);
    if (file == null) return;

    final fixed = await normalizeImageOrientation(file);
    final res = await ref
        .read(userVerificationControllerProvider.notifier)
        .uploadDocument(file: fixed, front: front);

    if (!mounted) return;
    res.fold(
      (failure) => ShowSnack(context, failure.message).error(),
      (_) => ShowSnack(
        context,
        front ? 'Front ID uploaded.' : 'Back ID uploaded.',
      ).success(),
    );
  }

  Future<void> _takeSelfie() async {
    File? file = await MediaHelper.pickImageFromCamera();
    if (!mounted) return;
    file ??= await MediaHelper.pickImageWithChoice(context);
    if (file == null) return;

    final fixed = await normalizeImageOrientation(file);
    final res = await ref
        .read(userVerificationControllerProvider.notifier)
        .uploadSelfie(fixed);

    if (!mounted) return;
    res.fold(
      (failure) => ShowSnack(context, failure.message).error(),
      (_) => ShowSnack(context, 'Selfie uploaded.').success(),
    );
  }

  Future<void> _showSubmittedDialog() async {
    final colors = context.appColors;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: colors.elevated,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: colors.amber.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_bottom_rounded,
                  color: colors.amber,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              Text('Submitted for Review', style: context.h4),
              const SizedBox(height: 12),
              Text(
                "We're reviewing your documents. Once approved, a blue badge appears next to your name.",
                textAlign: TextAlign.center,
                style: context.pMuted.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );

    if ((result ?? false) && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colors.surface,
        leading: IconButton(
          onPressed: state.isBusy ? null : _back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Get Verified', style: context.h4),
      ),
      body: Column(
        children: [
          _UserVerificationStepper(
            currentStep: state.currentStep,
            completed: state.completedSteps,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _PhoneStep(
                  phoneController: _phoneController,
                  otpController: _otpController,
                ),
                _IdentityStep(onUpload: _pickAndUploadDocument),
                _SelfieStep(onTakeSelfie: _takeSelfie),
                const _ReviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
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
                      onPressed: state.isBusy ? null : _back,
                      child: const Text('Back'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  text: state.currentStep == 3
                      ? 'Submit for Verification'
                      : 'Continue',
                  loading: state.isSubmitting,
                  onPressed: state.isBusy ? null : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserVerificationStepper extends StatelessWidget {
  const _UserVerificationStepper({
    required this.currentStep,
    required this.completed,
  });

  final int currentStep;
  final Set<int> completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      child: Row(
        children: List.generate(4, (i) {
          final done = completed.contains(i) && i < currentStep;
          final active = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? colors.success
                        : active
                        ? colors.primary
                        : colors.elevated,
                  ),
                  child: done
                      ? Icon(Icons.check_rounded, color: colors.white, size: 28)
                      : Text(
                          '${i + 1}',
                          style: context.pStrong.copyWith(
                            color: active ? colors.white : colors.textMuted,
                            fontSize: 18,
                          ),
                        ),
                ),
                if (i != 3)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: done ? colors.success : colors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: colors.primary, size: 34),
        ),
        const SizedBox(height: 28),
        Text(title, style: context.h3.copyWith(fontSize: 32)),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: context.pMuted.copyWith(fontSize: 16, height: 1.45),
        ),
      ],
    );
  }
}

class _PhoneStep extends ConsumerWidget {
  const _PhoneStep({
    required this.phoneController,
    required this.otpController,
  });

  final TextEditingController phoneController;
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.phone_android_rounded,
            title: 'Phone Verification',
            subtitle:
                "We'll send a verification code to your phone number to confirm it's yours.",
          ),
          const SizedBox(height: 34),
          Text('Phone Number', style: context.pStrong),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  draft.countryCode,
                  style: context.pStrong.copyWith(fontSize: 17),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      controller.updatePhone(phoneNumber: value),
                  decoration: const InputDecoration(hintText: '712 345 678'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isSendingOtp
                  ? null
                  : () async {
                      final res = await controller.sendOtp();
                      if (!context.mounted) return;
                      res.fold(
                        (failure) =>
                            ShowSnack(context, failure.message).error(),
                        (_) => ShowSnack(context, 'OTP sent.').success(),
                      );
                    },
              child: state.isSendingOtp
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Enter OTP', style: context.pStrong),
          const SizedBox(height: 10),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            onChanged: (value) => controller.updatePhone(otp: value),
            decoration: const InputDecoration(
              counterText: '',
              hintText: '000000',
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: state.isVerifyingOtp
                  ? null
                  : () async {
                      final res = await controller.verifyOtp();
                      if (!context.mounted) return;
                      res.fold(
                        (failure) =>
                            ShowSnack(context, failure.message).error(),
                        (_) => ShowSnack(context, 'Phone verified.').success(),
                      );
                    },
              child: Text(
                draft.phoneVerified ? 'Phone verified' : 'Verify OTP',
                style: TextStyle(
                  color: draft.phoneVerified ? colors.success : colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityStep extends ConsumerWidget {
  const _IdentityStep({required this.onUpload});

  final Future<void> Function({required bool front}) onUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.badge_outlined,
            title: 'Identity Document',
            subtitle:
                "Upload a clear photo of your government-issued ID. We accept National ID, Passport, or Driver's License.",
          ),
          const SizedBox(height: 28),
          Text('Select ID Type', style: context.pStrong),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['National ID', 'Passport', "Driver's License"].map((
              type,
            ) {
              final selected = draft.idType == type;
              return ChoiceChip(
                selected: selected,
                label: Text(type),
                onSelected: (_) => controller.setIdType(type),
                selectedColor: colors.primary,
                backgroundColor: colors.elevated,
                labelStyle: context.pStrong.copyWith(
                  color: selected ? colors.white : colors.textPrimary,
                ),
                side: BorderSide(
                  color: selected ? colors.primary : colors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text('Front of ID', style: context.pStrong),
          const SizedBox(height: 10),
          _UploadTile(
            title: 'Upload front side',
            uploaded: draft.hasFront,
            loading: state.isUploadingFront,
            onTap: () => onUpload(front: true),
          ),
          const SizedBox(height: 22),
          Text('Back of ID', style: context.pStrong),
          const SizedBox(height: 10),
          _UploadTile(
            title: 'Upload back side',
            uploaded: draft.hasBack,
            loading: state.isUploadingBack,
            onTap: () => onUpload(front: false),
          ),
          const SizedBox(height: 22),
          _GuidelinesCard(colors: colors),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.title,
    required this.uploaded,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final bool uploaded;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: uploaded ? colors.success : colors.border,
            width: uploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: uploaded
                    ? colors.success.withValues(alpha: .12)
                    : colors.surfaceBright,
                borderRadius: BorderRadius.circular(16),
              ),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(17),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      uploaded
                          ? Icons.check_rounded
                          : Icons.credit_card_rounded,
                      color: uploaded ? colors.success : colors.textMuted,
                    ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                uploaded ? 'Uploaded' : title,
                style: context.h6.copyWith(
                  color: uploaded ? colors.success : colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.add_a_photo_outlined,
              color: uploaded ? colors.success : colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidelinesCard extends StatelessWidget {
  const _GuidelinesCard({required this.colors});
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Ensure all corners are visible',
      'Avoid glare and shadows',
      'Text should be clearly readable',
      'Use original document (no photocopies)',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.blue.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.blue.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colors.blue),
              const SizedBox(width: 10),
              Text(
                'Photo Guidelines',
                style: context.pStrong.copyWith(color: colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: context.p.copyWith(
                      color: colors.blue,
                      fontSize: 22,
                      height: .9,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: context.p)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SelfieStep extends ConsumerWidget {
  const _SelfieStep({required this.onTakeSelfie});

  final Future<void> Function() onTakeSelfie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.face_rounded,
            title: 'Selfie Verification',
            subtitle:
                "Take a clear selfie of your face. We'll match it with your ID photo to verify your identity.",
          ),
          const SizedBox(height: 34),
          Center(
            child: InkWell(
              onTap: state.isUploadingSelfie ? null : onTakeSelfie,
              borderRadius: BorderRadius.circular(160),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.elevated,
                      border: Border.all(
                        color: draft.hasSelfie
                            ? colors.success
                            : colors.success,
                        width: 4,
                      ),
                    ),
                    child: state.isUploadingSelfie
                        ? const Center(child: CircularProgressIndicator())
                        : Icon(
                            Icons.person_rounded,
                            color: colors.textMuted,
                            size: 90,
                          ),
                  ),
                  if (draft.hasSelfie)
                    Positioned(
                      right: 16,
                      bottom: 20,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: colors.success,
                        child: Icon(
                          Icons.check_rounded,
                          color: colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Tips for a good selfie', style: context.h5),
          const SizedBox(height: 14),
          const _SelfieTip(
            icon: Icons.wb_sunny_outlined,
            title: 'Good Lighting',
            subtitle: 'Find a well-lit area, natural light works best',
          ),
          const _SelfieTip(
            icon: Icons.face_retouching_natural_outlined,
            title: 'Face the Camera',
            subtitle: 'Look directly at the camera, keep a neutral expression',
          ),
          const _SelfieTip(
            icon: Icons.visibility_off_outlined,
            title: 'No Obstructions',
            subtitle: 'Remove glasses, hats, or anything covering your face',
          ),
          const _SelfieTip(
            icon: Icons.center_focus_strong_outlined,
            title: 'Center Your Face',
            subtitle: 'Keep your face centered within the frame',
          ),
        ],
      ),
    );
  }
}

class _SelfieTip extends StatelessWidget {
  const _SelfieTip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surfaceBright,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.pStrong.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: context.pMuted.copyWith(height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.verified_outlined,
            title: 'Review & Submit',
            subtitle:
                'Please review your information before submitting for verification.',
          ),
          const SizedBox(height: 28),
          _ReviewTile(
            icon: Icons.phone_android_rounded,
            label: 'Phone Number',
            value: draft.fullPhoneNumber,
            ok: draft.phoneVerified,
          ),
          _ReviewTile(
            icon: Icons.badge_outlined,
            label: 'Identity Document',
            value: draft.idType,
            ok: draft.hasFront && draft.hasBack,
          ),
          _ReviewTile(
            icon: Icons.face_rounded,
            label: 'Selfie',
            value: 'Face verification photo',
            ok: draft.hasSelfie,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: .12),
                  colors.primary.withValues(alpha: .04),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.primary.withValues(alpha: .25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text('Verification Benefits', style: context.h5),
                  ],
                ),
                const SizedBox(height: 16),
                for (final benefit in const [
                  'Verified badge on your profile',
                  'Increased buyer trust',
                  'Higher visibility in search results',
                  'Priority customer support',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: colors.success,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(benefit, style: context.p)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'By submitting, you agree to our verification terms and privacy policy. Your documents are securely stored and only used for verification purposes.',
            style: context.pMuted.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: (ok ? colors.success : colors.amber).withValues(
                alpha: .12,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: ok ? colors.success : colors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.pMuted),
                Text(value, style: context.pStrong.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: ok ? colors.success : colors.amber,
            size: 30,
          ),
        ],
      ),
    );
  }
}
