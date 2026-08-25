import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_list_screen.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/chat_list_screen.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_clear_chat_dialog.dart';
import 'package:africaonlinestores/features/connect/conversations/application/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/delete_conversation_sheet.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
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

enum _ConnectMenuAction {
  selectConversations,
  markAllRead,
  markSelectedRead,
  clearSelectedChats,
  deleteSelectedConversations,
  starredMessages,
  clearCallLog,
  settings,
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  _ConnectTab _selectedTab = _ConnectTab.chats;
  bool _didResolveInitialTab = false;
  bool _searchVisible = false;
  bool _menuActionInFlight = false;
  bool _conversationSelectionMode = false;
  Set<String> _selectedConversationIds = <String>{};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    Future.microtask(
      () => ref.read(callManagerProvider.notifier).loadCallLogs(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResolveInitialTab) return;
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    _selectedTab = tab == 'calls' ? _ConnectTab.calls : _ConnectTab.chats;
    _didResolveInitialTab = true;
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openNewConversation() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    ConnectScreenNavigation.toNewConversation(context);
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchCtrl.clear();
    });
  }

  void _selectTab(_ConnectTab tab) {
    if (_selectedTab == tab) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTab = tab;
      _searchCtrl.clear();
      _conversationSelectionMode = false;
      _selectedConversationIds = <String>{};
    });
    if (tab == _ConnectTab.calls) {
      unawaited(ref.read(callManagerProvider.notifier).loadCallLogs());
    }
  }

  void _enterConversationSelection() {
    setState(() {
      _conversationSelectionMode = true;
      _searchVisible = false;
      _searchCtrl.clear();
    });
  }

  void _exitConversationSelection() {
    if (!_conversationSelectionMode && _selectedConversationIds.isEmpty) {
      return;
    }
    setState(() {
      _conversationSelectionMode = false;
      _selectedConversationIds = <String>{};
    });
  }

  void _setConversationSelected(String conversationId, bool selected) {
    final id = conversationId.trim();
    if (id.isEmpty) return;

    setState(() {
      final next = Set<String>.from(_selectedConversationIds);
      if (selected) {
        next.add(id);
        _conversationSelectionMode = true;
      } else {
        next.remove(id);
        if (next.isEmpty) _conversationSelectionMode = false;
      }
      _selectedConversationIds = next;
    });
  }

  void _applyBulkResult(ConversationBulkActionResult result) {
    if (!mounted) return;
    if (result.isComplete) {
      _exitConversationSelection();
      return;
    }
    setState(() {
      _selectedConversationIds = Set<String>.from(result.failedIds);
      _conversationSelectionMode = _selectedConversationIds.isNotEmpty;
    });
  }

  Future<void> _handleMenuAction(_ConnectMenuAction action) async {
    if (_menuActionInFlight) return;
    final l10n = AppLocalizations.of(context);

    switch (action) {
      case _ConnectMenuAction.selectConversations:
        _enterConversationSelection();
        return;
      case _ConnectMenuAction.starredMessages:
        ConnectScreenNavigation.toStarredMessages(context);
        return;
      case _ConnectMenuAction.settings:
        ConnectScreenNavigation.toChatSettings(context);
        return;
      case _ConnectMenuAction.markAllRead:
      case _ConnectMenuAction.markSelectedRead:
      case _ConnectMenuAction.clearSelectedChats:
      case _ConnectMenuAction.deleteSelectedConversations:
      case _ConnectMenuAction.clearCallLog:
        break;
    }

    _menuActionInFlight = true;
    try {
      if (action == _ConnectMenuAction.markAllRead) {
        final ok = await ref
            .read(conversationsControllerProvider.notifier)
            .markAllRead();
        if (!mounted) return;
        if (ok) {
          ShowSnack(context, l10n.chat_all_marked_read).success();
        } else {
          ShowSnack(context, l10n.chat_some_mark_read_failed).error();
        }
        return;
      }

      if (action == _ConnectMenuAction.markSelectedRead) {
        final result = await ref
            .read(conversationsControllerProvider.notifier)
            .markConversationsRead(_selectedConversationIds);
        if (!mounted) return;
        _applyBulkResult(result);
        if (result.isComplete) {
          ShowSnack(
            context,
            l10n.chat_selected_marked_read(result.succeededCount),
          ).success();
        } else {
          ShowSnack(context, l10n.chat_selected_action_partial_failure).error();
        }
        return;
      }

      if (action == _ConnectMenuAction.clearSelectedChats) {
        final selectedCount = _selectedConversationIds.length;
        if (selectedCount == 0) return;
        final confirmed = await showChatClearChatDialog(
          context,
          conversationCount: selectedCount,
        );
        if (confirmed != true || !mounted) return;

        final result = await ref
            .read(conversationsControllerProvider.notifier)
            .clearConversations(_selectedConversationIds);
        if (!mounted) return;
        _applyBulkResult(result);
        if (result.isComplete) {
          ShowSnack(
            context,
            l10n.chat_selected_chats_cleared(result.succeededCount),
          ).success();
        } else {
          ShowSnack(context, l10n.chat_selected_action_partial_failure).error();
        }
        return;
      }

      if (action == _ConnectMenuAction.deleteSelectedConversations) {
        final selected = Set<String>.from(_selectedConversationIds);
        if (selected.isEmpty) return;
        final conversations = ref.read(conversationsControllerProvider).value;
        String? displayName;
        if (selected.length == 1) {
          final selectedId = selected.single;
          for (final conversation
              in conversations ?? const <ChatConversation>[]) {
            if (conversation.id == selectedId) {
              displayName = conversation.displayName;
              break;
            }
          }
        }

        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DeleteConversationSheet(
            selectedCount: selected.length,
            displayName: displayName,
          ),
        );
        if (confirmed != true || !mounted) return;

        final result = await ref
            .read(conversationsControllerProvider.notifier)
            .deleteConversations(selected);
        if (!mounted) return;
        _applyBulkResult(result);
        if (result.isComplete) {
          ShowSnack(
            context,
            l10n.chat_selected_chats_deleted(result.succeededCount),
          ).success();
        } else {
          ShowSnack(context, l10n.chat_selected_action_partial_failure).error();
        }
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.chat_clear_call_log_title),
          content: Text(l10n.chat_clear_call_log_body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.chat_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.chat_clear),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      final ok = await ref
          .read(callManagerProvider.notifier)
          .clearCallHistory();
      if (!mounted) return;
      if (ok) {
        ShowSnack(context, l10n.chat_call_log_cleared).success();
      } else {
        ShowSnack(context, l10n.chat_call_log_clear_failed).error();
      }
    } finally {
      _menuActionInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final isChats = _selectedTab == _ConnectTab.chats;
    final unreadChats = ref.watch(chatUnreadCountProvider);
    final callState = ref.watch(callManagerProvider);
    final missedCalls = callState.callLogs
        .where((call) => call.isMissed)
        .length;
    final query = _searchCtrl.text;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ConnectHeader(
              selectedTab: _selectedTab,
              searchVisible: _searchVisible,
              selectionMode: isChats && _conversationSelectionMode,
              selectedCount: _selectedConversationIds.length,
              onSearchTap: _toggleSearch,
              onExitSelection: _exitConversationSelection,
              onMenuSelected: _handleMenuAction,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: !_searchVisible
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: AppSearchBar(
                        controller: _searchCtrl,
                        autofocus: true,
                        height: 48,
                        hintText: isChats
                            ? l10n.chat_search_chats_hint
                            : l10n.chat_search_calls_hint,
                        margin: EdgeInsets.zero,
                      ),
                    ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isChats
                    ? ChatListScreen(
                        key: const ValueKey('connect_chats'),
                        searchQuery: query,
                        selectionMode: _conversationSelectionMode,
                        selectedConversationIds: _selectedConversationIds,
                        onSelectionChanged: _setConversationSelected,
                      )
                    : CallListScreen(
                        key: const ValueKey('connect_calls'),
                        searchQuery: query,
                      ),
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

class _ConnectHeader extends StatelessWidget {
  const _ConnectHeader({
    required this.selectedTab,
    required this.searchVisible,
    required this.selectionMode,
    required this.selectedCount,
    required this.onSearchTap,
    required this.onExitSelection,
    required this.onMenuSelected,
  });

  final _ConnectTab selectedTab;
  final bool searchVisible;
  final bool selectionMode;
  final int selectedCount;
  final VoidCallback onSearchTap;
  final VoidCallback onExitSelection;
  final ValueChanged<_ConnectMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 8, 2),
      child: Row(
        children: [
          IconButton(
            tooltip: selectionMode
                ? l10n.chat_cancel_selection
                : l10n.chat_close_connect,
            onPressed: selectionMode
                ? onExitSelection
                : () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.goNamed(AppRoutes.nHome);
                    }
                  },
            icon: const Icon(Icons.close_rounded, size: 28),
          ),
          Expanded(
            child: Text(
              selectionMode
                  ? l10n.chat_selected_conversations(selectedCount)
                  : l10n.chat_connect_title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.h4.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (selectionMode)
            const SizedBox(width: 48)
          else
            IconButton(
              tooltip: searchVisible
                  ? l10n.chat_close_search
                  : l10n.chat_search,
              onPressed: onSearchTap,
              icon: Icon(
                searchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                size: 26,
              ),
            ),
          PopupMenuButton<_ConnectMenuAction>(
            enabled: !selectionMode || selectedCount > 0,
            tooltip: l10n.chat_more_options,
            color: colors.elevated,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
            offset: const Offset(0, 44),
            onSelected: onMenuSelected,
            itemBuilder: (context) {
              if (selectedTab == _ConnectTab.calls) {
                return [
                  PopupMenuItem(
                    value: _ConnectMenuAction.clearCallLog,
                    child: _MenuRow(
                      icon: Icons.delete_sweep_outlined,
                      label: l10n.chat_clear_call_log,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ConnectMenuAction.settings,
                    child: _MenuRow(
                      icon: Icons.settings_outlined,
                      label: l10n.chat_settings,
                    ),
                  ),
                ];
              }

              if (selectionMode) {
                return [
                  PopupMenuItem(
                    value: _ConnectMenuAction.markSelectedRead,
                    child: _MenuRow(
                      icon: Icons.mark_chat_read_outlined,
                      label: l10n.chat_mark_as_read,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ConnectMenuAction.clearSelectedChats,
                    child: _MenuRow(
                      icon: Icons.cleaning_services_outlined,
                      label: l10n.chat_clear_chats,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ConnectMenuAction.deleteSelectedConversations,
                    child: _MenuRow(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.chat_delete_conversations,
                      destructive: true,
                    ),
                  ),
                ];
              }

              return [
                PopupMenuItem(
                  value: _ConnectMenuAction.selectConversations,
                  child: _MenuRow(
                    icon: Icons.checklist_rounded,
                    label: l10n.chat_select_conversations,
                  ),
                ),
                PopupMenuItem(
                  value: _ConnectMenuAction.markAllRead,
                  child: _MenuRow(
                    icon: Icons.mark_chat_read_outlined,
                    label: l10n.chat_mark_all_read,
                  ),
                ),
                PopupMenuItem(
                  value: _ConnectMenuAction.starredMessages,
                  child: _MenuRow(
                    icon: Icons.star_border_rounded,
                    label: l10n.chat_starred_messages,
                  ),
                ),
                PopupMenuItem(
                  value: _ConnectMenuAction.settings,
                  child: _MenuRow(
                    icon: Icons.settings_outlined,
                    label: l10n.chat_settings,
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert_rounded, size: 26),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.appColors.red : null;
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: context.p.copyWith(fontSize: 14, color: color),
          ),
        ),
      ],
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
    final l10n = AppLocalizations.of(context);
    final barHeight = (52 + MediaQuery.textScalerOf(context).scale(12))
        .clamp(66.0, 96.0)
        .toDouble();

    return SafeArea(
      top: false,
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: colors.elevated,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomBarItem(
                label: l10n.chat_chats,
                icon: Icons.chat_bubble_rounded,
                badgeCount: unreadChats,
                selected: selectedTab == _ConnectTab.chats,
                onTap: () => onTabSelected(_ConnectTab.chats),
              ),
            ),
            Semantics(
              button: true,
              label: l10n.chat_new_conversation,
              child: InkResponse(
                radius: 34,
                onTap: onPlusTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.24),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.chat_new,
                      style: context.small.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                label: l10n.chat_calls,
                icon: Icons.call_rounded,
                badgeCount: missedCalls,
                selected: selectedTab == _ConnectTab.calls,
                onTap: () => onTabSelected(_ConnectTab.calls),
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
    final color = selected ? colors.primary : colors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badgeCount > 0)
                  Positioned(
                    right: -13,
                    top: -9,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: context.small.copyWith(
                          color: colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.small.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
