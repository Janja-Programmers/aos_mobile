import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountGuestHeaderCard extends StatelessWidget {
  const AccountGuestHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onLogin,
    this.onSignUp,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          children: [
            // Icon badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_outline,
                color: scheme.error.withValues(alpha: 0.85),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              l10n.account_guest_title,
              textAlign: TextAlign.center,
              style: context.h4,
            ),
            const SizedBox(height: 6),

            Text(
              l10n.account_guest_description,
              textAlign: TextAlign.center,
              style: context.pMuted,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed:
                          onLogin ??
                          () {
                            context.pushNamed(AppRoutes.nLogin);
                          },
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: scheme.onSurface.withValues(alpha: 0.30),
                        ),
                        foregroundColor: scheme.primary,
                      ),
                      child: Text(l10n.auth_login, style: context.p),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: FilledButton(
                      onPressed:
                          onSignUp ??
                          () {
                            context.pushNamed(AppRoutes.nRegister);
                          },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.surface,
                      ),
                      child: Text(
                        l10n.auth_register,
                        style: AppTextStylesX(context).button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
