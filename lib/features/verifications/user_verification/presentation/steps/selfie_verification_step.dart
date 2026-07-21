import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfieVerificationStep extends ConsumerWidget {
  const SelfieVerificationStep({
    super.key,
    required this.onChooseSelfie,
    required this.isPreparing,
  });

  final Future<void> Function() onChooseSelfie;
  final bool isPreparing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final draft = state.draft;
    final isLoading = state.isUploadingSelfie || isPreparing;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserVerificationStepHeader(
            icon: Icons.face_rounded,
            title: 'Selfie Verification',
            subtitle:
                "Take a clear selfie or upload one. We'll match it with your ID photo to verify your identity.",
          ),
          const SizedBox(height: 34),
          Center(
            child: InkWell(
              onTap: isLoading ? null : () => unawaited(onChooseSelfie()),
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
                            : colors.primary,
                        width: 4,
                      ),
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Icon(
                            draft.hasSelfie
                                ? Icons.person_rounded
                                : Icons.add_a_photo_outlined,
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
          const SizedBox(height: 22),
          Center(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () => unawaited(onChooseSelfie()),
              icon: Icon(
                draft.hasSelfie
                    ? Icons.refresh_rounded
                    : Icons.add_a_photo_outlined,
              ),
              label: Text(
                draft.hasSelfie ? 'Replace selfie' : 'Take or upload selfie',
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
