import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_list_screen.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/chat_list_screen.dart';
// import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_story_template_strip.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

enum _ConnectTab { chats, calls }

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _searchCtrl = TextEditingController();
  _ConnectTab _selectedTab = _ConnectTab.chats;
  bool _didResolveInitialTab = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(callManagerProvider.notifier).loadCallLogs();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didResolveInitialTab) return;

    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    _selectedTab = tab == 'calls' ? _ConnectTab.calls : _ConnectTab.chats;
    _didResolveInitialTab = true;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openNewConversation() async {
    await HapticFeedback.selectionClick();

    if (!mounted) return;
    ConnectScreenNavigation.toNewConversation(context);
  }

  void _selectTab(_ConnectTab tab) {
    if (_selectedTab == tab) return;

    HapticFeedback.selectionClick();
    setState(() => _selectedTab = tab);

    if (tab == _ConnectTab.calls) {
      ref.read(callManagerProvider.notifier).loadCallLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isChats = _selectedTab == _ConnectTab.chats;
    final unreadChats = ref.watch(chatUnreadCountProvider);
    final callState = ref.watch(callManagerProvider);
    final missedCalls = callState.callLogs
        .where((call) => call.isMissed)
        .length;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ConnectHeader(onNewConversation: _openNewConversation),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
              child: AppSearchBar(
                controller: _searchCtrl,
                readOnly: true,
                hintText: 'Search...',
                margin: EdgeInsets.zero,
                onTap: _openNewConversation,
              ),
            ),
            // ConnectStoryTemplateStrip(
            //   onCreateStory: () =>
            //       ConnectScreenNavigation.toCreateStory(context),
            //   onStoryTap: (story) =>
            //       ConnectScreenNavigation.toStoryViewer(context, story.id),
            // ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isChats
                    ? const ChatListScreen(key: ValueKey('connect_chats'))
                    : const CallListScreen(key: ValueKey('connect_calls')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ConnectBottomBar(
        selectedTab: _selectedTab,
        unreadChats: unreadChats,
        missedCalls: missedCalls,
        onTabSelected: _selectTab,
        onPlusTap: _openNewConversation,
      ),
    );
  }
}

class _ConnectHeader extends ConsumerWidget {
  const _ConnectHeader({required this.onNewConversation});

  final VoidCallback onNewConversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 4),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.close_rounded,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.goNamed(AppRoutes.nHome);
              }
            },
          ),
          Expanded(
            child: Text(
              'AOS Connect',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.h4.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PopupMenuButton<int>(
            color: colors.elevated,
            surfaceTintColor: Colors.transparent,
            shadowColor: colors.black.withValues(alpha: 0.18),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.border),
            ),
            offset: const Offset(0, 54),
            onSelected: (index) => AppNavigation.goTo(context, ref, index),
            itemBuilder: (context) {
              final items = AppNavConfig.items(context);
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (i) {
                final item = items[i];
                final isActive = location.contains(item.routeName);
                final itemColor = isActive
                    ? colors.primary
                    : colors.textPrimary;

                return PopupMenuItem<int>(
                  value: i,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, color: itemColor),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: context.p.copyWith(color: itemColor),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
            child: const _HeaderIconButton(icon: Icons.menu_rounded),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, color: colors.textPrimary, size: 30),
        ),
      ),
    );
  }
}

class _ConnectBottomBar extends StatelessWidget {
  const _ConnectBottomBar({
    required this.selectedTab,
    required this.unreadChats,
    required this.missedCalls,
    required this.onTabSelected,
    required this.onPlusTap,
  });

  final _ConnectTab selectedTab;
  final int unreadChats;
  final int missedCalls;
  final ValueChanged<_ConnectTab> onTabSelected;
  final VoidCallback onPlusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 24,
              right: 24,
              bottom: 14,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomBarItem(
                        label: 'Chats',
                        icon: Icons.chat_bubble_rounded,
                        badgeCount: unreadChats,
                        selected: selectedTab == _ConnectTab.chats,
                        onTap: () => onTabSelected(_ConnectTab.chats),
                      ),
                    ),
                    const SizedBox(width: 82),
                    Expanded(
                      child: _BottomBarItem(
                        label: 'Calls',
                        icon: Icons.call_rounded,
                        badgeCount: missedCalls,
                        selected: selectedTab == _ConnectTab.calls,
                        onTap: () => onTabSelected(_ConnectTab.calls),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPlusTap,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 7),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add_rounded, color: colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.label,
    required this.icon,
    required this.badgeCount,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int badgeCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final activeColor = colors.primary;
    final inactiveColor = colors.textMuted;
    final color = selected ? activeColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 28),
              if (badgeCount > 0)
                Positioned(
                  right: -10,
                  top: -12,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: context.small.copyWith(
                        color: colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.p.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
