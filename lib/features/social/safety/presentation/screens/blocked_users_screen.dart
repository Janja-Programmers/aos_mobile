import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/safety/data/social_safety_api.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

final blockedUsersProvider =
    FutureProvider.autoDispose<List<SocialUserSummary>>((ref) async {
      final res = await ref.read(socialSafetyApiProvider).listBlockedUsers();
      return res.fold((f) => throw Exception(f.message), (items) => items);
    });

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    String user,
  ) async {
    final res = await ref
        .read(socialSafetyApiProvider)
        .unblockUser(targetUser: user);
    if (!context.mounted) return;
    res.fold((f) => ShowSnack(context, f.message).error(), (_) {
      ref.invalidate(blockedUsersProvider);
      ShowSnack(context, 'User unblocked.').success();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final asyncUsers = ref.watch(blockedUsersProvider);
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Blocked users', style: context.h5)),
      body: asyncUsers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e.toString(), style: context.pMuted)),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Text('No blocked users', style: context.pMuted),
            );
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: colors.border),
            itemBuilder: (_, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatar?.isNotEmpty == true
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar?.isNotEmpty == true
                      ? null
                      : const Icon(Icons.person_outline_rounded),
                ),
                title: Text(user.displayName),
                subtitle: Text(user.user),
                trailing: OutlinedButton(
                  onPressed: () => _unblock(context, ref, user.user),
                  child: const Text('Unblock'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
