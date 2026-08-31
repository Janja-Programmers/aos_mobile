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
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
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
            ShowSnack(
              context,
              AppLocalizations.of(context).chat_failed_to_start_call,
            ).error();
          }
        },
      );
    } catch (_) {
      if (mounted) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_call,
        ).error();
      }
    } finally {
      _isStartingCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            _SegmentedTabs(selectedTab: _selectedTab, onChanged: _changeTab),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: AppSearchBar(
                controller: _searchController,
                autofocus: true,
                height: 48,
                hintText: _selectedTab == _NewConversationTab.sellers
                    ? l10n.chat_search_sellers_hint
                    : l10n.chat_search_friends_hint,
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.chat_back,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              l10n.chat_new_conversation,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.h4.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
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
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: l10n.chat_verified_sellers,
            selected: selectedTab == _NewConversationTab.sellers,
            onTap: () => onChanged(_NewConversationTab.sellers),
          ),
          _SegmentButton(
            label: l10n.chat_friends,
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
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              color: selected ? colors.white : colors.textMuted,
              fontSize: 14,
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sellerListControllerProvider);
    final controller = ref.read(sellerListControllerProvider.notifier);

    if (state.isLoadingInitial && state.items.isEmpty) {
      return _CenteredState(
        icon: Icons.storefront_outlined,
        title: l10n.chat_loading_sellers,
        message: l10n.chat_loading_sellers_hint,
        showSpinner: true,
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return _CenteredState(
        icon: Icons.error_outline_rounded,
        title: l10n.chat_could_not_load_sellers,
        message: state.error!.message,
        actionText: l10n.chat_retry,
        onAction: controller.retry,
      );
    }

    if (state.items.isEmpty) {
      return _CenteredState(
        icon: Icons.search_off_rounded,
        title: state.search.isEmpty
            ? l10n.chat_no_verified_sellers
            : l10n.chat_no_sellers_found,
        message: state.search.isEmpty
            ? l10n.chat_no_verified_sellers_hint
            : l10n.chat_no_sellers_found_hint,
        actionText: l10n.chat_refresh,
        onAction: controller.retry,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(socialConnectionsControllerProvider(args));
    final controller = ref.read(
      socialConnectionsControllerProvider(args).notifier,
    );
    final items = state.items;

    if (state.isLoading && items.isEmpty) {
      return _CenteredState(
        icon: Icons.people_alt_outlined,
        title: l10n.chat_loading_friends,
        message: l10n.chat_loading_friends_hint,
        showSpinner: true,
      );
    }

    if (state.hasError && items.isEmpty) {
      return _CenteredState(
        icon: Icons.error_outline_rounded,
        title: l10n.chat_could_not_load_friends,
        message: state.errorMessage ?? l10n.chat_try_again,
        actionText: l10n.chat_retry,
        onAction: controller.refresh,
      );
    }

    if (items.isEmpty) {
      return _CenteredState(
        icon: Icons.search_off_rounded,
        title: state.query.isEmpty
            ? l10n.chat_no_friends_yet
            : l10n.chat_no_friends_found,
        message: state.query.isEmpty
            ? l10n.chat_no_friends_yet_hint
            : l10n.chat_no_friends_found_hint,
        actionText: l10n.chat_refresh,
        onAction: controller.refresh,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
          subtitle: _friendSubtitle(friend, l10n),
          avatarUrl: friend.userImage,
          initial: _initial(friend.initials),
          verified: friend.isVerified,
          online: friend.isFriend,
          onMessage: () => onMessage(friend),
          onCall: () => onCall(friend),
        );
      },
    );
  }

  String _friendSubtitle(SocialFriend friend, AppLocalizations l10n) {
    if (friend.isFriend) return l10n.chat_online;
    if (friend.followedBackAt != null) return l10n.chat_last_seen_recently;
    if (friend.followedAt != null) return l10n.chat_last_seen_recently;
    return l10n.chat_friend;
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
    final l10n = AppLocalizations.of(context);
    final imageUrl = buildFileUrl(avatarUrl);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final useStackedLayout = textScale > 1.35;

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.primary.withValues(alpha: 0.16),
          backgroundImage: imageUrl == null
              ? null
              : AppImageDecode.networkProvider(
                  context,
                  imageUrl,
                  logicalWidth: 48,
                  logicalHeight: 48,
                ),
          child: imageUrl == null
              ? Text(
                  initial,
                  style: context.h5.copyWith(
                    color: colors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colors.elevated, width: 2),
              ),
            ),
          ),
      ],
    );

    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: useStackedLayout ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: context.h5.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (verified) ...[const SizedBox(width: 5), const VerifiedBadge()],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: useStackedLayout ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: context.pMuted.copyWith(fontSize: 14),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundActionButton(
          semanticLabel: l10n.chat_message_contact,
          icon: Icons.chat_bubble_rounded,
          iconColor: colors.primary,
          backgroundColor: colors.primary.withValues(alpha: 0.13),
          onTap: onMessage,
        ),
        const SizedBox(width: 4),
        _RoundActionButton(
          semanticLabel: l10n.chat_call_contact,
          icon: Icons.call_rounded,
          iconColor: colors.success,
          backgroundColor: colors.success.withValues(alpha: 0.13),
          onTap: onCall,
        ),
      ],
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: useStackedLayout
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: actions,
                ),
              ],
            )
          : Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(child: details),
                const SizedBox(width: 6),
                actions,
              ],
            ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.semanticLabel,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
            ),
          ),
        ),
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
      child: SingleChildScrollView(
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
