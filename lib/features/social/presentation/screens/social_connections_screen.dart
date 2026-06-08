import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/application/providers/social_connections_provider.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connections_app_bar.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connections_list.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connections_search.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connections_tabs.dart';

class SocialConnectionsScreen extends ConsumerStatefulWidget {
  final String title;
  final SocialConnectionsTab initialTab;
  final String? targetUser;

  const SocialConnectionsScreen({
    super.key,
    this.title = 'Connections',
    this.initialTab = SocialConnectionsTab.followers,
    this.targetUser,
  });

  @override
  ConsumerState<SocialConnectionsScreen> createState() =>
      _SocialConnectionsScreenState();
}

class _SocialConnectionsScreenState
    extends ConsumerState<SocialConnectionsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final args = SocialConnectionsArgs(
      initialTab: widget.initialTab,
      targetUser: widget.targetUser,
    );

    final state = ref.watch(socialConnectionsControllerProvider(args));

    final controller = ref.read(
      socialConnectionsControllerProvider(args).notifier,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: SocialConnectionsAppBar(
        title: widget.title,
        onAddTap: () {
          // TODO: add/invite people route.
        },
      ),
      body: Column(
        children: [
          SocialConnectionsTabs(
            selectedTab: state.selectedTab,
            followingCount: state.followingCount,
            followersCount: state.followersCount,
            friendsCount: state.friendsCount,
            onChanged: controller.changeTab,
          ),
          SocialConnectionsSearch(
            controller: _searchCtrl,
            onChanged: controller.updateQuery,
          ),
          Expanded(
            child: SocialConnectionsList(
              state: state,
              onRefresh: controller.refresh,
            ),
          ),
        ],
      ),
    );
  }
}
