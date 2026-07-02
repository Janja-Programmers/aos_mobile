import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_list_controller.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';
import 'package:africaonlinestores/features/social/application/providers/social_connections_provider.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _NewConversationTab { sellers, friends }

class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() =>
      _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  static const _friendsArgs = SocialConnectionsArgs(
    initialTab: SocialConnectionsTab.friends,
  );

  final _searchController = TextEditingController();
  final _sellerScrollController = ScrollController();
  final _friendScrollController = ScrollController();

  _NewConversationTab _selectedTab = _NewConversationTab.sellers;
  bool _isStartingCall = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      ref.read(sellerListControllerProvider.notifier).loadInitial();
    });

    _sellerScrollController.addListener(_onSellerScroll);
    _friendScrollController.addListener(_onFriendScroll);
  }

  @override
  void dispose() {
    _sellerScrollController.removeListener(_onSellerScroll);
    _friendScrollController.removeListener(_onFriendScroll);
    _sellerScrollController.dispose();
    _friendScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSellerScroll() {
    if (!_sellerScrollController.hasClients) return;

    final position = _sellerScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      ref.read(sellerListControllerProvider.notifier).loadMore();
    }
  }

  void _onFriendScroll() {
    if (!_friendScrollController.hasClients) return;

    final position = _friendScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      ref
          .read(socialConnectionsControllerProvider(_friendsArgs).notifier)
          .loadMore();
    }
  }

  void _changeTab(_NewConversationTab tab) {
    if (_selectedTab == tab) return;

    HapticFeedback.selectionClick();
    setState(() => _selectedTab = tab);
    _syncSearch(_searchController.text);
  }

  void _syncSearch(String value) {
    switch (_selectedTab) {
      case _NewConversationTab.sellers:
        ref.read(sellerListControllerProvider.notifier).updateSearch(value);
        break;
      case _NewConversationTab.friends:
        ref
            .read(socialConnectionsControllerProvider(_friendsArgs).notifier)
            .updateQuery(value);
        break;
    }
  }

  Future<void> _messageSeller(SellerListItem seller) async {
    if (seller.user.trim().isEmpty || seller.isSelf) return;

    await AppNavigation.requireAuth(
      context,
      ref,
      onAuthenticated: () {
        ChatActions.startChat(
          context: context,
          ref: ref,
          user: seller.user,
          displayName: seller.displayName,
          avatar: seller.avatar,
        );
      },
    );
  }

  Future<void> _messageFriend(SocialFriend friend) async {
    if (friend.user.trim().isEmpty || friend.isSelf) return;

    await AppNavigation.requireAuth(
      context,
      ref,
      onAuthenticated: () {
        ChatActions.startChat(
          context: context,
          ref: ref,
          user: friend.user,
          displayName: friend.displayName,
          avatar: friend.userImage,
        );
      },
    );
  }

  Future<void> _callSeller(SellerListItem seller) async {
    if (seller.user.trim().isEmpty || seller.isSelf) return;

    await _startAudioCall(
      userId: seller.user,
      displayName: seller.displayName,
      avatar: seller.avatar,
    );
  }

  Future<void> _callFriend(SocialFriend friend) async {
    if (friend.user.trim().isEmpty || friend.isSelf) return;

    await _startAudioCall(
      userId: friend.user,
      displayName: friend.displayName,
      avatar: friend.userImage,
    );
  }

  Future<void> _startAudioCall({
    required String userId,
    required String displayName,
    String? avatar,
  }) async {
    if (_isStartingCall) return;

    _isStartingCall = true;

    try {
      await AppNavigation.requireAuth(
        context,
        ref,
        onAuthenticated: () async {
          await HapticFeedback.mediumImpact();

          final started = await ref
              .read(callStarterServiceProvider)
              .startOutgoingCall(
                userId: userId,
                callType: AOSCallType.audio,
                receiver: CallParticipant(
                  userId: userId,
                  displayName: displayName,
                  avatarUrl: avatar,
                ),
              );

          if (!started && mounted) {
            ShowSnack(context, 'Failed to start call').error();
          }
        },
      );
    } catch (_) {
      if (mounted) {
        ShowSnack(context, 'Failed to start call').error();
      }
    } finally {
      _isStartingCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            _SegmentedTabs(selectedTab: _selectedTab, onChanged: _changeTab),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
              child: AppSearchBar(
                controller: _searchController,
                autofocus: true,
                hintText: _selectedTab == _NewConversationTab.sellers
                    ? 'Search sellers...'
                    : 'Search friends...',
                margin: EdgeInsets.zero,
                onChanged: _syncSearch,
                onSubmitted: _syncSearch,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _selectedTab == _NewConversationTab.sellers
                    ? _SellerResults(
                        key: const ValueKey('sellers'),
                        scrollController: _sellerScrollController,
                        onMessage: _messageSeller,
                        onCall: _callSeller,
                      )
                    : _FriendResults(
                        key: const ValueKey('friends'),
                        args: _friendsArgs,
                        scrollController: _friendScrollController,
                        onMessage: _messageFriend,
                        onCall: _callFriend,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 28, 18),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.textPrimary,
                  size: 30,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'New Conversation',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.h4.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selectedTab, required this.onChanged});

  final _NewConversationTab selectedTab;
  final ValueChanged<_NewConversationTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Verified Sellers',
            selected: selectedTab == _NewConversationTab.sellers,
            onTap: () => onChanged(_NewConversationTab.sellers),
          ),
          _SegmentButton(
            label: 'Friends',
            selected: selectedTab == _NewConversationTab.friends,
            onTap: () => onChanged(_NewConversationTab.friends),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              color: selected ? colors.white : colors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerResults extends ConsumerWidget {
  const _SellerResults({
    super.key,
    required this.scrollController,
    required this.onMessage,
    required this.onCall,
  });

  final ScrollController scrollController;
  final ValueChanged<SellerListItem> onMessage;
  final ValueChanged<SellerListItem> onCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerListControllerProvider);
    final controller = ref.read(sellerListControllerProvider.notifier);

    if (state.isLoadingInitial && state.items.isEmpty) {
      return const _CenteredState(
        icon: Icons.storefront_outlined,
        title: 'Loading sellers',
        message: 'Please wait while we find verified sellers.',
        showSpinner: true,
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return _CenteredState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load sellers',
        message: state.error!.message,
        actionText: 'Retry',
        onAction: controller.retry,
      );
    }

    if (state.items.isEmpty) {
      return _CenteredState(
        icon: Icons.search_off_rounded,
        title: state.search.isEmpty
            ? 'No verified sellers'
            : 'No sellers found',
        message: state.search.isEmpty
            ? 'Verified sellers will appear here when available.'
            : 'Try another seller name, category, or location.',
        actionText: 'Refresh',
        onAction: controller.retry,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final seller = state.items[index];
        return _ContactCard(
          title: seller.displayName,
          subtitle: seller.displayCategory,
          avatarUrl: seller.avatar,
          initial: _initial(seller.displayName),
          verified: seller.isVerified,
          online: seller.isFriend,
          onMessage: () => onMessage(seller),
          onCall: () => onCall(seller),
        );
      },
    );
  }
}

class _FriendResults extends ConsumerWidget {
  const _FriendResults({
    super.key,
    required this.args,
    required this.scrollController,
    required this.onMessage,
    required this.onCall,
  });

  final SocialConnectionsArgs args;
  final ScrollController scrollController;
  final ValueChanged<SocialFriend> onMessage;
  final ValueChanged<SocialFriend> onCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialConnectionsControllerProvider(args));
    final controller = ref.read(
      socialConnectionsControllerProvider(args).notifier,
    );
    final items = state.items;

    if (state.isLoading && items.isEmpty) {
      return const _CenteredState(
        icon: Icons.people_alt_outlined,
        title: 'Loading friends',
        message: 'Please wait while we find your friends.',
        showSpinner: true,
      );
    }

    if (state.hasError && items.isEmpty) {
      return _CenteredState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load friends',
        message: state.errorMessage ?? 'Please try again.',
        actionText: 'Retry',
        onAction: controller.refresh,
      );
    }

    if (items.isEmpty) {
      return _CenteredState(
        icon: Icons.search_off_rounded,
        title: state.query.isEmpty ? 'No friends yet' : 'No friends found',
        message: state.query.isEmpty
            ? 'Friends will appear here once you follow each other.'
            : 'Try searching with another name or email.',
        actionText: 'Refresh',
        onAction: controller.refresh,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final friend = items[index];
        return _ContactCard(
          title: friend.displayName,
          subtitle: _friendSubtitle(friend),
          avatarUrl: friend.userImage,
          initial: friend.initials.characters.first,
          verified: friend.isVerified,
          online: friend.isFriend,
          onMessage: () => onMessage(friend),
          onCall: () => onCall(friend),
        );
      },
    );
  }

  String _friendSubtitle(SocialFriend friend) {
    if (friend.isFriend) return 'Online';
    if (friend.followedBackAt != null) return 'Last seen recently';
    if (friend.followedAt != null) return 'Last seen recently';
    return 'Friend';
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    required this.initial,
    required this.verified,
    required this.online,
    required this.onMessage,
    required this.onCall,
  });

  final String title;
  final String subtitle;
  final String? avatarUrl;
  final String initial;
  final bool verified;
  final bool online;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUrl = buildFileUrl(avatarUrl);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 92),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.primary.withValues(alpha: 0.16),
                  backgroundImage: imageUrl == null
                      ? null
                      : NetworkImage(imageUrl),
                  child: imageUrl == null
                      ? Text(
                          initial,
                          style: context.h5.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                if (online)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.elevated, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.h5.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 7),
                        Icon(
                          Icons.verified_rounded,
                          color: colors.blue,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pMuted.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _RoundActionButton(
              icon: Icons.chat_bubble_rounded,
              iconColor: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: 0.13),
              onTap: onMessage,
            ),
            const SizedBox(width: 12),
            _RoundActionButton(
              icon: Icons.call_rounded,
              iconColor: colors.success,
              backgroundColor: colors.success.withValues(alpha: 0.13),
              onTap: onCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 27),
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.showSpinner = false,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showSpinner;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 46, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.h5.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: context.pMuted),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _initial(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return '?';
  return clean.characters.first.toUpperCase();
}
