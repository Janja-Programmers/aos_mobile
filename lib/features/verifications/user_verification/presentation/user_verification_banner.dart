import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';

class UserVerificationBanner extends StatelessWidget {
  const UserVerificationBanner({super.key, required this.status});

  final UserVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status.status) {
      case VerificationStatus.approved:
        return _VerificationStatusCard(
          icon: Icons.verified_rounded,
          iconColor: context.appColors.blue,
          title: 'Verified Account',
          subtitle: 'Your identity has been verified',
          borderColor: context.appColors.blue.withOpacity(.4),
        );
      case VerificationStatus.pending:
        return _VerificationStatusCard(
          icon: Icons.hourglass_bottom_rounded,
          iconColor: context.appColors.amber,
          title: 'Verification in Review',
          subtitle: "We're reviewing your identity documents",
          borderColor: context.appColors.amber.withOpacity(.45),
        );
      case VerificationStatus.rejected:
        return _VerificationStatusCard(
          icon: Icons.error_outline_rounded,
          iconColor: context.appColors.primary,
          title: 'Verification Needs Update',
          subtitle: status.rejectionReason?.trim().isNotEmpty == true
              ? status.rejectionReason!.trim()
              : 'Please update your details and submit again',
          borderColor: context.appColors.primary.withOpacity(.35),
          onTap: () => context.pushNamed(AppRoutes.nUserVerification),
        );
      case VerificationStatus.notSubmitted:
        return _VerificationStatusCard(
          icon: Icons.shield_outlined,
          iconColor: context.appColors.blue,
          title: 'Get Verified',
          subtitle: 'Verify your identity to earn a blue badge',
          onTap: () => context.pushNamed(AppRoutes.nUserVerification),
        );
    }
  }
}

class _VerificationStatusCard extends StatelessWidget {
  const _VerificationStatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor ?? colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: context.h5.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.pMuted.copyWith(height: 1.25),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textMuted,
                  size: 30,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
