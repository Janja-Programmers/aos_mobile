import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';

import 'package:africaonlinestores/ui/components/account_option_tile.dart';
import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';
import 'package:africaonlinestores/ui/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Account'),
        leading: _CircleIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          _CircleIconButton(
            icon: Icons.favorite_border,
            onPressed: () {
              showAppSnack(context, 'Account comings soon!');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.fieldBg,
                backgroundImage: (user?.userImage.isNotEmpty == true)
                    ? NetworkImage(
                        '${AppConfig.normalizedBaseUrl}${user!.userImage}',
                      )
                    : null,
                child: (user?.userImage.isNotEmpty == true)
                    ? null
                    : Text(
                        (user?.fullName.isNotEmpty ?? false)
                            ? user!.fullName
                                  .trim()
                                  .substring(0, 1)
                                  .toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName
                          : 'Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(fontSize: 13, color: colors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const _SectionTitle('Account settings'),

          const SizedBox(height: 6),
          AccountOptionTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () {
              context.push(AppRoutes.updateProfile);
            },
          ),

          const Divider(height: 1),
          AccountOptionTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            onTap: () {
              context.push(AppRoutes.passwordSecurity);
            },
          ),

          const Divider(height: 1),
          AccountOptionTile(
            icon: Icons.notifications_none,
            title: 'Notifications Preferences',
            onTap:() {
              context.push(AppRoutes.notifications);
            },
          ),

          const SizedBox(height: 18),
          const _SectionTitle('Other'),

          const SizedBox(height: 6),
          AccountOptionTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              context.push(AppRoutes.terms);
            },
          ),

          const Divider(height: 1),
          AccountOptionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              context.push(AppRoutes.privacy);
            },
          ),

          const Divider(height: 1),
          AccountOptionTile(
            icon: Icons.language_outlined,
            title: 'Language',
            onTap: () {
              showAppSnack(context, 'Language coming soon!');
            },
          ),

          const SizedBox(height: 22),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                final parentContext = context;

                await showModalBottomSheet<void>(
                  context: parentContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) {
                    return AppConfirmSheet(
                      icon: Icons.error_outline,
                      iconBg: Theme.of(parentContext).colorScheme.error,
                      title: 'Logout',
                      message:
                          'Are you sure you want to log out? You will need to sign in again to access your account.',
                      primaryText: 'Logout',
                      secondaryText: 'Cancel',
                      onPrimary: () async {
                        // Close the sheet first using the sheet context
                        Navigator.of(sheetContext).pop();

                        // Then perform logout
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();

                        // Navigate using the parent context (guard its mounted)
                        if (!parentContext.mounted) return;
                        parentContext.go(AppRoutes.home);
                      },
                      onSecondary: () {
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(borderRadius: _pill),
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
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.h2.copyWith(fontSize: 16));
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: _pill,
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.fieldBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
