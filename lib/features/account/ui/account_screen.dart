import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';

import 'package:africaonlinestores/features/account/ui/widgets/account_guest_header_card.dart';
import 'package:africaonlinestores/features/account/ui/widgets/account_sections.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';

import 'package:africaonlinestores/shared/components/account_option_tile.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/shared/components/app_switch_tile.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Widget _buildAccountHeader(BuildContext context, user) {
    if (user == null) {
      return AccountGuestHeaderCard(
        onLogin: () => context.pushNamed(AppRoutes.nLogin),
        onSignUp: () => context.pushNamed(AppRoutes.nRegister),
      );
    }

    return AccountHeaderCard(
      fullName: user.fullName.isNotEmpty ? user.fullName : 'Account',
      email: user.email,
      initials: _initialsFromName(user.fullName),
      baseUrl: AppConfig.normalizedBaseUrl,
      imagePath: user.userImage.isNotEmpty ? user.userImage : null,
      onEdit: () => context.pushNamed(AppRoutes.nUpdateProfile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text('Account', style: context.h4),
        leading: _CircleIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.nHome);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        children: [
          _buildAccountHeader(context, user),
          const SizedBox(height: 14),

          GetVerifiedBanner(
            onTap: () {
              ShowSnack(context, 'Coming Soon!').info();
              // context.push(AppRoutes.getVerified);
            },
          ),
          const SizedBox(height: 18),

          const AccountSectionTitle('Account settings'),
          const SizedBox(height: 8),

          AccountCard(
            child: Column(
              children: [
                if (user != null)
                  AccountOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Password & Security',
                    onTap: () => context.pushNamed(AppRoutes.nPasswordSecurity),
                  ),

                AccountOptionTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications Preferences',
                  onTap: () => context.pushNamed(AppRoutes.nNotifications),
                ),

                AppSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: isDarkMode,
                  showDivider: false,
                  onChanged: (val) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const AccountSectionTitle('Other'),
          const SizedBox(height: 8),

          AccountCard(
            child: Column(
              children: [
                AccountOptionTile(
                  icon: Icons.language_outlined,
                  title: 'Preferences',
                  onTap: () => context.pushNamed(AppRoutes.nPreference),
                ),
                AccountOptionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => context.pushNamed(AppRoutes.nPrivacy),
                ),
                AccountOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  showDivider: false,
                  onTap: () => context.pushNamed(AppRoutes.nTerms),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (user != null) ...[
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final parentContext = context;

                  await showModalBottomSheet<void>(
                    context: parentContext,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) {
                      return AppConfirmSheet(
                        icon: Icons.warning_rounded,
                        iconBg: scheme.primary,
                        title: 'Logout',
                        message:
                            'Are you sure you want to log out? You will need to sign in again to access your account.',
                        primaryText: 'Logout',
                        secondaryText: 'Cancel',
                        onPrimary: () async {
                          Navigator.of(sheetContext).pop();
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                          if (!parentContext.mounted) return;
                          parentContext.go(AppRoutes.home);
                        },
                        onSecondary: () => Navigator.of(sheetContext).pop(),
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: BorderSide(color: scheme.error),
                  foregroundColor: scheme.error,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static String _initialsFromName(String? name) {
    final n = (name)!.trim();
    if (n.isEmpty) return 'U';
    return n.substring(0, 1).toUpperCase();
  }
}

/// Reusable rounded card wrapper (matches target look)
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.surfaceBright,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
