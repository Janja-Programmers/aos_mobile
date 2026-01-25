import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/config/app_config.dart';
import 'package:aos_mobile/features/account/providers/accounts_controller.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/shared/widgets/account_option_tile.dart';
import 'package:aos_mobile/shared/widgets/app_bottom_nav.dart';
import 'package:aos_mobile/shared/widgets/app_confirm_sheet.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountsControllerProvider);
    final profile = account.profile;

    final fullName = (profile['full_name'] ?? '').toString();
    final email = (profile['email'] ?? '').toString();
    final userImage = (profile['user_image'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
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
              // TODO
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(accountsControllerProvider.notifier).loadProfile(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEDEDED),
                  backgroundImage: userImage.isNotEmpty
                      ? NetworkImage('${AppConfig.normalizedBaseUrl}$userImage')
                      : null,
                  child: userImage.isNotEmpty
                      ? null
                      : Text(
                          fullName.trim().isNotEmpty
                              ? fullName.trim().substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.trim().isNotEmpty ? fullName : 'Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (account.loading) const SizedBox(width: 6),
                if (account.loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            if (account.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                account.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

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
              onTap: () {
                // TODO
              },
            ),

            const SizedBox(height: 18),
            const _SectionTitle('Other'),
            const SizedBox(height: 6),
            AccountOptionTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => context.push(AppRoutes.terms),
            ),
            const Divider(height: 1),
            AccountOptionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => context.push(AppRoutes.privacy),
            ),
            const Divider(height: 1),
            AccountOptionTile(
              icon: Icons.language_outlined,
              title: 'Language',
              onTap: () {
                // TODO
              },
            ),

            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AppConfirmSheet(
                      icon: Icons.error_outline,
                      iconBg: const Color(0xFFE65A5A),
                      title: 'Logout',
                      message:
                          'Are you sure you want to log out? You will need to sign in again to access your account.',
                      primaryText: 'Logout',
                      secondaryText: 'Cancel',
                      onPrimary: () async {
                        Navigator.of(context).pop(); // close sheet
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go(AppRoutes.home);
                      },
                      onSecondary: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: const BorderSide(color: Color(0xFFE65A5A)),
                  foregroundColor: const Color(0xFFE65A5A),
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
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}
