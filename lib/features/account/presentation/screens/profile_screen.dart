import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }

    final user = auth.user;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Me',
          style: context.h2,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// AVATAR
            CircleAvatar(
              radius: 58,
              backgroundColor: colors.primary.withOpacity(.1),
              backgroundImage: user.userImage.isNotEmpty
                  ? NetworkImage(
                      '${AppConfig.normalizedBaseUrl}${user.userImage}',
                    )
                  : null,
              child: user.userImage.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: colors.primary,
                    )
                  : null,
            ),

            const SizedBox(height: 18),

            /// NAME
            Text(
              user.fullName,
              style: context.h1,
            ),

            const SizedBox(height: 6),

            /// USERNAME
            Text(
              '@${user.email}',
              style: context.p,
            ),

            const SizedBox(height: 20),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _StatItem(
                  value: '142',
                  label: 'Following',
                ),
                _Divider(),
                const _StatItem(
                  value: '3.8K',
                  label: 'Followers',
                ),
                _Divider(),
                const _StatItem(
                  value: '24.5K',
                  label: 'Likes',
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// BIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                user.bio ?? '',
                textAlign: TextAlign.center,
                style: context.p,
              ),
            ),

            const SizedBox(height: 24),

            /// EDIT BUTTON
            SizedBox(
              width: 240,
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ProfileEditSheet(),
                  );
                },
                child: const Text('Edit profile'),
              ),
            ),

            const SizedBox(height: 24),

            /// TABS
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.grid_view),
                Icon(Icons.bookmark_border),
                Icon(Icons.favorite_border),
              ],
            ),

            const SizedBox(height: 12),

            /// GRID PLACEHOLDER
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              padding: EdgeInsets.zero,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (_, index) {
                return Container(
                  color: Colors.grey.shade300,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      color: Colors.grey.shade300,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.h2,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.p
        ),
      ],
    );
  }
}