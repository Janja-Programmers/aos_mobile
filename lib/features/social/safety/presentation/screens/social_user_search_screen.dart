import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/safety/application/social_safety_controller.dart';
import 'package:africaonlinestores/features/social/safety/data/social_safety_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialUserSearchScreen extends ConsumerStatefulWidget {
  const SocialUserSearchScreen({super.key});

  @override
  ConsumerState<SocialUserSearchScreen> createState() =>
      _SocialUserSearchScreenState();
}

class _SocialUserSearchScreenState
    extends ConsumerState<SocialUserSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(socialUserSearchControllerProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(socialUserSearchControllerProvider);
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Find people', style: context.h5)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search users',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: state.items.isEmpty
                ? Center(
                    child: Text(
                      state.query.length < 2
                          ? 'Search by name or email'
                          : 'No users found',
                      style: context.pMuted,
                    ),
                  )
                : ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: colors.border),
                    itemBuilder: (_, index) {
                      final user = state.items[index];
                      return _UserSearchTile(user: user);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  const _UserSearchTile({required this.user});

  final SocialUserSummary user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatar?.isNotEmpty ?? false
            ? NetworkImage(user.avatar!)
            : null,
        child: user.avatar?.isNotEmpty ?? false
            ? null
            : const Icon(Icons.person_outline_rounded),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified_rounded, size: 16),
          ],
          if (user.isLive) ...[const SizedBox(width: 6), const _LiveBadge()],
        ],
      ),
      subtitle: Text(
        user.followersDisplay.isEmpty
            ? user.user
            : '${user.followersDisplay} followers',
      ),
      onTap: () => SocialNavigation.toProfileScreen(
        context,
        user: user.user,
        displayName: user.displayName,
        avatar: user.avatar,
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
