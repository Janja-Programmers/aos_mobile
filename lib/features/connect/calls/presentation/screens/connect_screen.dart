import 'package:flutter/material.dart';

enum ContactTab { calls, messages }

enum CallType { incoming, outgoing, missed }

class CallLogItem {
  final String id;
  final String name;
  final String subtitle;
  final CallType type;
  final bool highlightRed;
  final String section;

  CallLogItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.section,
    this.highlightRed = false,
  });

  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class MessageItem {
  final String id;
  final String name;
  final String preview;
  final String time;
  final int unreadCount;

  MessageItem({
    required this.id,
    required this.name,
    required this.preview,
    required this.time,
    this.unreadCount = 0,
  });

  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ContactTab _tab = ContactTab.messages;
  final Duration _switchDuration = const Duration(milliseconds: 260);

  final TextEditingController _searchController = TextEditingController();

  int _selectedCallFilter = 0;
  int _selectedMessageFilter = 0;

  late List<CallLogItem> _calls;
  late List<MessageItem> _messages;

  @override
  void initState() {
    super.initState();

    _calls = [
      CallLogItem(
        id: 'c1',
        name: 'TechHub Kenya',
        subtitle: '10:32 AM • 5:23',
        type: CallType.incoming,
        section: 'Today',
      ),
      CallLogItem(
        id: 'c2',
        name: 'Jane Mwangi',
        subtitle: '9:45 AM',
        type: CallType.missed,
        section: 'Today',
        highlightRed: true,
      ),
      CallLogItem(
        id: 'c3',
        name: 'Peter Ochieng',
        subtitle: '8:30 AM • 12:45',
        type: CallType.outgoing,
        section: 'Today',
      ),
      CallLogItem(
        id: 'c4',
        name: 'Mary Wanjiku',
        subtitle: '6:15 PM',
        type: CallType.missed,
        section: 'Yesterday',
        highlightRed: true,
      ),
      CallLogItem(
        id: 'c5',
        name: 'John Kamau',
        subtitle: '3:20 PM • 8:12',
        type: CallType.incoming,
        section: 'Yesterday',
      ),
      CallLogItem(
        id: 'c6',
        name: 'Electronics Plus',
        subtitle: '11:48 AM • 2:31',
        type: CallType.outgoing,
        section: 'Yesterday',
      ),
    ];

    _messages = [
      MessageItem(
        id: 'm1',
        name: 'TechHub Kenya',
        preview: 'Yes, the iPhone is still available. W...',
        time: '10:32AM',
        unreadCount: 3,
      ),
      MessageItem(
        id: 'm2',
        name: 'Jane Mwangi',
        preview: 'I can do Ksh 140,000 for the MacB...',
        time: '9:45AM',
        unreadCount: 1,
      ),
      MessageItem(
        id: 'm3',
        name: 'Peter Ochieng',
        preview: 'Thanks for the purchase! Enjoy ...',
        time: 'Yesterday',
      ),
      MessageItem(
        id: 'm4',
        name: 'Nairobi Electronics',
        preview: 'We have restocked the Samsun...',
        time: 'Yesterday',
        unreadCount: 2,
      ),
      MessageItem(
        id: 'm5',
        name: 'Mary Wanjiku',
        preview: 'Is the price negotiable? I am in Westl...',
        time: 'Mon',
      ),
      MessageItem(
        id: 'm6',
        name: 'David Kimani',
        preview: 'Can you send more photos of the lo...',
        time: '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isCalls = _tab == ContactTab.calls;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: _buildFab(isCalls),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SegmentedTabs(
                selected: _tab,
                onChanged: (tab) {
                  setState(() {
                    _tab = tab;
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                controller: _searchController,
                hintText: isCalls ? 'Search calls...' : 'Search messages...',
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isCalls ? _buildCallFilters() : _buildMessageFilters(),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: _switchDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: _tab == ContactTab.calls
                        ? const Offset(-0.06, 0)
                        : const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: isCalls
                    ? _CallsListView(
                        key: const ValueKey('calls_view'),
                        items: _filteredCalls(),
                        onDelete: (id) {
                          setState(() {
                            _calls.removeWhere((e) => e.id == id);
                          });
                        },
                      )
                    : _MessagesListView(
                        key: const ValueKey('messages_view'),
                        items: _filteredMessages(),
                        onDelete: (id) {
                          setState(() {
                            _messages.removeWhere((e) => e.id == id);
                          });
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          selected: _selectedCallFilter == 0,
          onTap: () => setState(() => _selectedCallFilter = 0),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Missed',
          selected: _selectedCallFilter == 1,
          onTap: () => setState(() => _selectedCallFilter = 1),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Incoming',
          selected: _selectedCallFilter == 2,
          onTap: () => setState(() => _selectedCallFilter = 2),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Outgoing',
          selected: _selectedCallFilter == 3,
          onTap: () => setState(() => _selectedCallFilter = 3),
        ),
      ],
    );
  }

  Widget _buildMessageFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'All Chat',
          selected: _selectedMessageFilter == 0,
          onTap: () => setState(() => _selectedMessageFilter = 0),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Read',
          selected: _selectedMessageFilter == 1,
          onTap: () => setState(() => _selectedMessageFilter = 1),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Unread',
          selected: _selectedMessageFilter == 2,
          onTap: () => setState(() => _selectedMessageFilter = 2),
        ),
        const SizedBox(width: 18),
        _FilterChip(
          label: 'Unanswered',
          selected: _selectedMessageFilter == 3,
          onTap: () => setState(() => _selectedMessageFilter = 3),
        ),
      ],
    );
  }

  List<CallLogItem> _filteredCalls() {
    final query = _searchController.text.trim().toLowerCase();

    return _calls.where((item) {
      final matchesQuery =
          query.isEmpty || item.name.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedCallFilter) {
        0 => true,
        1 => item.type == CallType.missed,
        2 => item.type == CallType.incoming,
        3 => item.type == CallType.outgoing,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<MessageItem> _filteredMessages() {
    final query = _searchController.text.trim().toLowerCase();

    return _messages.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.preview.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedMessageFilter) {
        0 => true,
        1 => item.unreadCount == 0,
        2 => item.unreadCount > 0,
        3 => item.unreadCount > 0,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Widget _buildFab(bool isCalls) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: isCalls ? const Color(0xFF33C56D) : const Color(0xFFD4081E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isCalls ? Icons.add_call : Icons.message_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final ContactTab selected;
  final ValueChanged<ContactTab> onChanged;

  const _SegmentedTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTabButton(
              active: selected == ContactTab.calls,
              label: 'Calls',
              icon: Icons.call_rounded,
              onTap: () => onChanged(ContactTab.calls),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SegmentTabButton(
              active: selected == ContactTab.messages,
              label: 'Messages',
              icon: Icons.chat_bubble_rounded,
              onTap: () => onChanged(ContactTab.messages),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabButton extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SegmentTabButton({
    required this.active,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD4081E) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: active ? Colors.white : const Color(0xFF616161),
                  size: 27,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF616161),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _SearchBar({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDADADA), width: 1.4),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF959595), size: 38),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 18, color: Color(0xFF333333)),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9B9B9B),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFEED9DD) : Colors.transparent;
    final fg = selected ? const Color(0xFFBC1D2C) : const Color(0xFF5D5D5D);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CallsListView extends StatelessWidget {
  final List<CallLogItem> items;
  final ValueChanged<String> onDelete;

  const _CallsListView({
    super.key,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CallLogItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }

    final sections = grouped.entries.toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        for (final entry in sections) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(title: entry.key),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = entry.value[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: const _DeleteBackground(),
                onDismissed: (_) => onDelete(item.id),
                child: _CallTile(item: item),
              );
            }, childCount: entry.value.length),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _MessagesListView extends StatelessWidget {
  final List<MessageItem> items;
  final ValueChanged<String> onDelete;

  const _MessagesListView({
    super.key,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(title: '', compact: true),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: const _DeleteBackground(),
              onDismissed: (_) => onDelete(item.id),
              child: _MessageTile(item: item),
            );
          }, childCount: items.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool compact;

  const _StickyHeaderDelegate({required this.title, this.compact = false});

  @override
  double get minExtent => compact ? 6 : 52;

  @override
  double get maxExtent => compact ? 6 : 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (compact) {
      return Container(color: const Color(0xFFF5F5F5));
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D5D5D),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || compact != oldDelegate.compact;
  }
}

class _CallTile extends StatelessWidget {
  final CallLogItem item;

  const _CallTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (item.type) {
      CallType.incoming => Icons.call_received_rounded,
      CallType.outgoing => Icons.call_made_rounded,
      CallType.missed => Icons.call_missed_rounded,
    };

    final iconColor = switch (item.type) {
      CallType.incoming => const Color(0xFF36C46D),
      CallType.outgoing => const Color(0xFF555555),
      CallType.missed => const Color(0xFFC31626),
    };

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _InitialAvatar(initial: item.initial),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: item.highlightRed
                        ? const Color(0xFFBC1D2C)
                        : const Color(0xFF161616),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(iconData, size: 23, color: iconColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8B8B8B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.call_rounded, color: Color(0xFF33C56D), size: 34),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final MessageItem item;

  const _MessageTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InitialAvatar(initial: item.initial),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF676767),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          item.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF626262),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.unreadCount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFC81124),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;

  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      height: 94,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w700,
          color: Color(0xFF171717),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC81124),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 26),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', active: false),
          _NavItem(
            icon: Icons.grid_view_outlined,
            label: 'Categories',
            active: false,
          ),
          _SellNavButton(),
          _NavItem(
            icon: Icons.perm_contact_calendar_outlined,
            label: 'Contact',
            active: true,
            boxed: true,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Account',
            active: false,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool boxed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFBC1D2C) : const Color(0xFF8A8A8A);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (boxed)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEEDFE1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 31),
          )
        else
          Icon(icon, color: color, size: 34),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFFBC1D2C) : const Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}

class _SellNavButton extends StatelessWidget {
  const _SellNavButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: const BoxDecoration(
            color: Color(0xFFD4081E),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 42),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sell',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}
