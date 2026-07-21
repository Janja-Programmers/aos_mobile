import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

enum AccountVerificationBannerTone { available, pending, rejected, unavailable }

class AccountVerificationBanner extends StatelessWidget {
  const AccountVerificationBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.onTap,
    this.busy = false,
  });

  final String title;
  final String subtitle;
  final AccountVerificationBannerTone tone;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = switch (tone) {
      AccountVerificationBannerTone.available => colors.primary,
      AccountVerificationBannerTone.pending => colors.amber,
      AccountVerificationBannerTone.rejected => colors.error,
      AccountVerificationBannerTone.unavailable => colors.error,
    };
    final icon = switch (tone) {
      AccountVerificationBannerTone.available => Icons.shield_outlined,
      AccountVerificationBannerTone.pending => Icons.schedule_rounded,
      AccountVerificationBannerTone.rejected => Icons.error_outline_rounded,
      AccountVerificationBannerTone.unavailable => Icons.cloud_off_outlined,
    };
    final background = Color.alphaBlend(
      accent.withValues(alpha: 0.08),
      colors.elevated,
    );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null && !busy,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.32)),
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox.square(
                    dimension: 42,
                    child: Icon(icon, color: accent, size: 23),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.smallMuted.copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (busy)
                  SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textMuted,
                    size: 25,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
