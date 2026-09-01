import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_body.dart';
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

    return UserVerificationStepBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserVerificationStepHeader(
            icon: Icons.face_rounded,
            title: 'Selfie Verification',
            subtitle:
                "Take a clear selfie or upload one. We'll match it with your ID photo to verify your identity.",
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final selfieExtent = (constraints.maxWidth * 0.52).clamp(
                152.0,
                184.0,
              );
              final personIconSize = selfieExtent * 0.34;

              return Center(
                child: InkWell(
                  onTap: isLoading ? null : () => unawaited(onChooseSelfie()),
                  borderRadius: BorderRadius.circular(selfieExtent / 2),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: selfieExtent,
                        height: selfieExtent,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.elevated,
                          border: Border.all(
                            color: draft.hasSelfie
                                ? colors.success
                                : colors.primary,
                            width: 3,
                          ),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Icon(
                                draft.hasSelfie
                                    ? Icons.person_rounded
                                    : Icons.add_a_photo_outlined,
                                color: colors.textMuted,
                                size: personIconSize,
                              ),
                      ),
                      if (draft.hasSelfie)
                        PositionedDirectional(
                          end: 8,
                          bottom: 12,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: colors.success,
                            child: Icon(
                              Icons.check_rounded,
                              color: colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 22),
          Text(
            'Tips for a good selfie',
            style: context.h6.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceBright,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.textPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.pStrong),
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
