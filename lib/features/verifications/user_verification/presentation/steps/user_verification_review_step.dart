import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserVerificationReviewStep extends ConsumerWidget {
  const UserVerificationReviewStep({super.key});

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
          const UserVerificationStepHeader(
            icon: Icons.verified_outlined,
            title: 'Review & Submit',
            subtitle:
                'Please review your information before submitting for verification.',
          ),
          const SizedBox(height: 28),
          _ReviewTile(
            icon: Icons.person_outline_rounded,
            label: 'Legal Name',
            value: draft.legalName.trim(),
            ok: draft.hasLegalName,
          ),
          _ReviewTile(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: draft.phoneNumber.trim(),
            ok: draft.hasPhoneNumber,
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
                  colors.primary.withValues(alpha: 0.12),
                  colors.primary.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
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
    final displayedValue = value.trim().isEmpty ? 'Not provided' : value;

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
                alpha: 0.12,
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
                Text(
                  displayedValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.pStrong.copyWith(fontSize: 16),
                ),
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
