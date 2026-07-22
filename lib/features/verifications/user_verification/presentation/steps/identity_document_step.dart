import 'dart:async';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserVerificationStepHeader(
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
          const SizedBox(height: 28),
          Text('Front of ID', style: context.pStrong),
          const SizedBox(height: 10),
          _UploadTile(
            title: 'Take or upload front side',
            uploaded: draft.hasFront,
            loading: state.isUploadingFront || isPreparingFront,
            onTap: () => unawaited(onUpload(front: true)),
          ),
          const SizedBox(height: 22),
          Text('Back of ID', style: context.pStrong),
          const SizedBox(height: 10),
          _UploadTile(
            title: 'Take or upload back side',
            uploaded: draft.hasBack,
            loading: state.isUploadingBack || isPreparingBack,
            onTap: () => unawaited(onUpload(front: false)),
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
                    ? colors.success.withValues(alpha: 0.12)
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
    const tips = [
      'Ensure all corners are visible',
      'Avoid glare and shadows',
      'Text should be clearly readable',
      'Use original document (no photocopies)',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.blue.withValues(alpha: 0.45)),
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
                      height: 0.9,
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
