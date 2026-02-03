import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// Guest header card used on Account screen when user is NOT authenticated.
/// Store: lib/ui/screens/account/widgets/account_guest_header_card.dart
///
/// Usage:
///   const AccountGuestHeaderCard()
///
/// Optional:
///   AccountGuestHeaderCard(
///     onLogin: () => context.push(AppRoutes.login),
///     onSignUp: () => context.push(AppRoutes.signUp),
///   )
class AccountGuestHeaderCard extends StatelessWidget {
  const AccountGuestHeaderCard({
    super.key,
    this.title = 'Welcome to AOS',
    this.subtitle =
        'Sign in to access your account, manage listings, and more.',
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

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
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
                color: scheme.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_outline,
                color: scheme.error.withOpacity(0.85),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),

            Text(title, textAlign: TextAlign.center, style: context.h4),
            const SizedBox(height: 6),

            Text(subtitle, textAlign: TextAlign.center, style: context.pMuted),
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
                            context.push(AppRoutes.login);
                          },
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: scheme.onSurface.withOpacity(0.30),
                        ),
                        foregroundColor: scheme.primary,
                      ),
                      child: Text('Login', style: context.p),
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
                            context.push(AppRoutes.register);
                          },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.surface,
                      ),
                      child: Text('Register', style: context.button),
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
