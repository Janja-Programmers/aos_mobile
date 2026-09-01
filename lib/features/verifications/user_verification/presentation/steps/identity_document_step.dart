import 'dart:async';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_body.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentityDocumentStep extends ConsumerWidget {
  const IdentityDocumentStep({
    super.key,
    required this.onUpload,
    required this.isPreparingFront,
    required this.isPreparingBack,
  });

  final Future<void> Function({required bool front}) onUpload;
  final bool isPreparingFront;
  final bool isPreparingBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final draft = state.draft;

    return UserVerificationStepBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserVerificationStepHeader(
            icon: Icons.badge_outlined,
            title: 'Identity Document',
            subtitle:
                "Upload a clear photo of your government-issued ID. We accept National ID, Passport, or Driver's License.",
          ),
          const SizedBox(height: 20),
          Text('Select ID Type', style: context.pStrong),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const ['National ID', 'Passport', "Driver's License"].map(
              (type) {
                final selected = draft.idType == type;

                return ChoiceChip(
                  selected: selected,
                  label: Text(type),
                  onSelected: state.isBusy
                      ? null
                      : (_) => controller.setIdType(type),
                  selectedColor: colors.primary,
                  backgroundColor: colors.elevated,
                  labelStyle: context.pStrong.copyWith(
                    color: selected ? colors.white : colors.textPrimary,
                  ),
                  side: BorderSide(
                    color: selected ? colors.primary : colors.border,
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 20),
          Text('Front of ID', style: context.pStrong),
          const SizedBox(height: 8),
          _UploadTile(
            title: 'Take or upload front side',
            uploaded: draft.hasFront,
            loading: state.isUploadingFront || isPreparingFront,
            onTap: () => unawaited(onUpload(front: true)),
          ),
          const SizedBox(height: 16),
          Text('Back of ID', style: context.pStrong),
          const SizedBox(height: 8),
          _UploadTile(
            title: 'Take or upload back side',
            uploaded: draft.hasBack,
            loading: state.isUploadingBack || isPreparingBack,
            onTap: () => unawaited(onUpload(front: false)),
          ),
          const SizedBox(height: 18),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploaded ? colors.success : colors.border,
            width: uploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: uploaded
                    ? colors.success.withValues(alpha: 0.12)
                    : colors.surfaceBright,
                borderRadius: BorderRadius.circular(14),
              ),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      uploaded
                          ? Icons.check_rounded
                          : Icons.credit_card_rounded,
                      color: uploaded ? colors.success : colors.textMuted,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                uploaded ? 'Uploaded' : title,
                style: context.pStrong.copyWith(
                  color: uploaded ? colors.success : colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.add_a_photo_outlined,
              color: uploaded ? colors.success : colors.primary,
              size: 22,
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
    const tips = [
      'Ensure all corners are visible',
      'Avoid glare and shadows',
      'Text should be clearly readable',
      'Use original document (no photocopies)',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.blue.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Photo Guidelines',
                style: context.pStrong.copyWith(color: colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: context.p.copyWith(
                      color: colors.blue,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: context.p)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
