import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/chat_list_screen.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_list_screen.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';

import 'package:africaonlinestores/shared/components/app_search_bar.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final selectedTab = _resolveIndex(context);

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text("Connect", style: context.h4),
      ),

      body: Column(
        children: [
          _buildToggleTabs(),

          const SizedBox(height: 12),

          _buildSearchBar(selectedTab == 1 ? "Messages" : "Calls"),

          const SizedBox(height: 12),

          Expanded(
            child: selectedTab == 1
                ? ChatListScreen(
                    key: ValueKey('${selectedTab}_${_searchCtrl.text}'),
                    searchQuery: _searchCtrl.text,
                  )
                : CallListScreen(
                    key: ValueKey('${selectedTab}_${_searchCtrl.text}'),
                    searchQuery: _searchCtrl.text,
                  ),
          ),
        ],
      ),

      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildToggleTabs() {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton("Calls", 0, Icons.call),
          _tabButton("Messages", 1, Icons.message),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index, IconData icon) {
    final selectedTab = _resolveIndex(context);
    final isSelected = selectedTab == index;
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _searchCtrl.clear();

          if (index == 0) {
            ConnectScreenNavigation.toCallsTab(context);
          } else {
            ConnectScreenNavigation.toMessagesTab(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? colors.white : colors.black),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? colors.white : colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AppSearchBar(
        hintText: "Search $title...",
        controller: _searchCtrl,
        readOnly: false,
      ),
    );
  }

  Widget _buildFAB() {
    final colors = context.appColors;
    final selectedTab = _resolveIndex(context);
    final isMessages = selectedTab == 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: FloatingActionButton(
        key: ValueKey(selectedTab),
        backgroundColor: colors.primary,
        onPressed: () {
          if (isMessages) {
            ChatNavigation.toNewMessage(context);
          } else {
            CallNavigation.toNewCall(ref);
          }
        },
        child: Icon(
          isMessages ? Icons.message : Icons.add_call,
          color: colors.white,
        ),
      ),
    );
  }

  int _resolveIndex(BuildContext context) {
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];

    switch (tab) {
      case 'calls':
        return 0;
      case 'messages':
      default:
        return 1;
    }
  }
}
