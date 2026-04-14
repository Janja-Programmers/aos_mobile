import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_filter_utils.dart';

class CallListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;

  const CallListScreen({super.key, this.searchQuery});

  @override
  ConsumerState<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends ConsumerState<CallListScreen> {
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();

    // 🔥 Load once
    Future.microtask(() {
      ref.read(callManagerProvider.notifier).loadCallLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);

    // ⏳ LOADING
    if (state.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ ERROR
    if (state.historyErrorMessage != null) {
      return Center(child: Text(state.historyErrorMessage!));
    }

    // 📦 DATA
    final filtered = CallFilterUtils.apply(
      calls: state.callLogs,
      query: widget.searchQuery ?? '',
      filter: selectedFilter,
    );

    final grouped = _groupCalls(filtered);

    return Column(
      children: [
        _buildFilters(),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(callManagerProvider.notifier).loadCallLogs();
            },
            child: ListView(
              children: grouped.entries.map((entry) {
                return _buildSection(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 📅 GROUPING
  Map<String, List<CallLog>> _groupCalls(List<CallLog> calls) {
    final now = DateTime.now();

    final Map<String, List<CallLog>> grouped = {"Today": [], "Yesterday": []};

    for (var call in calls) {
      final date = call.createdAt;

      if (_isSameDay(date, now)) {
        grouped["Today"]!.add(call);
      } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
        grouped["Yesterday"]!.add(call);
      }
    }

    return grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 🎯 FILTERS
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _chip("All", "all"),
          _chip("Missed", "missed"),
          _chip("Incoming", "incoming"),
          _chip("Outgoing", "outgoing"),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final colors = context.appColors;
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withOpacity(0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.primary : colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // 📦 SECTION
  Widget _buildSection(String title, List<CallLog> calls) {
    if (calls.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...calls.map(_callTile),
      ],
    );
  }

  // 📞 TILE
  Widget _callTile(CallLog call) {
    final colors = context.appColors;
    final isMissed = call.isMissed;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.border,
        child: Text(call.displayName.isNotEmpty ? call.displayName[0] : "?"),
      ),

      title: Text(
        call.displayName,
        style: TextStyle(
          color: isMissed ? Colors.red : colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Row(
        children: [
          Icon(
            call.direction == "incoming"
                ? Icons.call_received
                : Icons.call_made,
            size: 16,
            color: isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(call.formattedTime),
        ],
      ),

      trailing: const Icon(Icons.call, color: Colors.green),

      onTap: () {},
    );
  }
}
