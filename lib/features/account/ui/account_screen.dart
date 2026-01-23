import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/config/app_config.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/shared/widgets/account_option_tile.dart';
import 'package:aos_mobile/shared/widgets/app_bottom_nav.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

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
              // TODO: route to favourites when implemented
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
                backgroundColor: const Color(0xFFEDEDED),
                backgroundImage: (user?.userImage.isNotEmpty == true)
                    ? NetworkImage('${AppConfig.normalizedBaseUrl}${user!.userImage}')
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
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName
                          : 'Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
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
              // TODO
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
              // TODO
            },
          ),

          const SizedBox(height: 22),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.home);
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

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
