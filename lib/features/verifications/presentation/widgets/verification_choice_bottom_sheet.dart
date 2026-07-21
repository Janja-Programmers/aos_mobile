import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_type.dart';
import 'package:flutter/material.dart';

enum VerificationChoice {
  individual(VerificationType.individual),
  business(VerificationType.business);

  const VerificationChoice(this.verificationType);

  final VerificationType verificationType;
}

Future<VerificationChoice?> showVerificationChoiceBottomSheet({
  required BuildContext context,
  required VerificationStatus? individualStatus,
  required VerificationStatus? businessStatus,
  required bool individualUnavailable,
  required bool businessUnavailable,
  String? individualRejectionReason,
  String? businessRejectionReason,
}) {
  return showModalBottomSheet<VerificationChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.46),
    builder: (sheetContext) {
      return VerificationChoiceBottomSheet(
        individualStatus: individualStatus,
        businessStatus: businessStatus,
        individualUnavailable: individualUnavailable,
        businessUnavailable: businessUnavailable,
        individualRejectionReason: individualRejectionReason,
        businessRejectionReason: businessRejectionReason,
      );
    },
  );
}

class VerificationChoiceBottomSheet extends StatelessWidget {
  const VerificationChoiceBottomSheet({
    super.key,
    required this.individualStatus,
    required this.businessStatus,
    required this.individualUnavailable,
    required this.businessUnavailable,
    this.individualRejectionReason,
    this.businessRejectionReason,
  });

  final VerificationStatus? individualStatus;
  final VerificationStatus? businessStatus;
  final bool individualUnavailable;
  final bool businessUnavailable;
  final String? individualRejectionReason;
  final String? businessRejectionReason;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.elevated,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const SizedBox(width: 42, height: 4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Get Verified',
                      style: context.h6.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                "Choose what you'd like to verify",
                style: context.smallMuted,
              ),
              const SizedBox(height: 16),
              _VerificationChoiceTile(
                icon: Icons.person_outline_rounded,
                title: 'Individual',
                subtitle: _individualSubtitle(),
                status: individualStatus,
                unavailable: individualUnavailable,
                onTap: () =>
                    Navigator.of(context).pop(VerificationChoice.individual),
              ),
              const SizedBox(height: 10),
              _VerificationChoiceTile(
                icon: Icons.business_center_outlined,
                title: 'Business',
                subtitle: _businessSubtitle(),
                status: businessStatus,
                unavailable: businessUnavailable,
                onTap: () =>
                    Navigator.of(context).pop(VerificationChoice.business),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _individualSubtitle() {
    if (individualUnavailable) {
      return 'Unable to check identity status. Pull down to refresh';
    }

    return switch (individualStatus) {
      VerificationStatus.pending =>
        'Your identity verification is currently under review',
      VerificationStatus.approved => 'Your identity is already verified',
      VerificationStatus.rejected => _rejectionSubtitle(
        individualRejectionReason,
        fallback: 'Update your identity details and submit again',
      ),
      VerificationStatus.notSubmitted ||
      null => 'Verify your identity to earn a blue badge',
    };
  }

  String _businessSubtitle() {
    if (businessUnavailable) {
      return 'Unable to check business status. Pull down to refresh';
    }

    return switch (businessStatus) {
      VerificationStatus.pending =>
        'Your business verification is currently under review',
      VerificationStatus.approved => 'Your business is already verified',
      VerificationStatus.rejected => _rejectionSubtitle(
        businessRejectionReason,
        fallback: 'Update your business details and submit again',
      ),
      VerificationStatus.notSubmitted ||
      null => 'Get verified as a registered business',
    };
  }

  String _rejectionSubtitle(String? reason, {required String fallback}) {
    final cleaned = reason?.trim() ?? '';
    return cleaned.isEmpty ? fallback : cleaned;
  }
}

class _VerificationChoiceTile extends StatelessWidget {
  const _VerificationChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.unavailable,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VerificationStatus? status;
  final bool unavailable;
  final VoidCallback onTap;

  bool get _enabled {
    return !unavailable &&
        status != VerificationStatus.pending &&
        status != VerificationStatus.approved;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = unavailable
        ? colors.error
        : status == VerificationStatus.rejected
        ? colors.error
        : status == VerificationStatus.pending
        ? colors.amber
        : colors.info;

    return Semantics(
      button: _enabled,
      enabled: _enabled,
      label: '$title. $subtitle',
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox.square(
                      dimension: 42,
                      child: Icon(icon, color: accent, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.pStrong),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: context.smallMuted.copyWith(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (unavailable)
                    Icon(Icons.error_outline_rounded, color: accent, size: 22)
                  else if (status == VerificationStatus.pending)
                    Icon(Icons.schedule_rounded, color: accent, size: 22)
                  else if (status == VerificationStatus.approved)
                    Icon(
                      Icons.verified_rounded,
                      color: colors.success,
                      size: 22,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textMuted,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
