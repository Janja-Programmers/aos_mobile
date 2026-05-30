import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_filter_utils.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/show_call_details_sheet.dart';
import 'package:africaonlinestores/features/connect/converaation/presentation/widgets/connect_state_view.dart';

import 'package:africaonlinestores/shared/utils/format_time.dart';

class CallListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;
  final bool hideFilters;

  const CallListScreen({super.key, this.searchQuery, this.hideFilters = false});

  @override
  ConsumerState<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends ConsumerState<CallListScreen> {
  String selectedFilter = "all";
  String _query = '';

  @override
  void initState() {
    super.initState();

    _query = widget.searchQuery ?? '';

    // 🔥 Load once
    Future.microtask(() {
      ref.read(callManagerProvider.notifier).loadCallLogs();
    });
  }

  @override
  void didUpdateWidget(covariant CallListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 react to search changes (MATCHES CHAT LIST)
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {
        _query = widget.searchQuery ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: widget.hideFilters
              ? const SizedBox.shrink()
              : _buildFilters(state),
        ),

        Expanded(child: _buildBody(state)),
      ],
    );
  }

  // -------------------------
  // BODY (handles loading/error/data)
  // -------------------------
  Widget _buildBody(CallState state) {
    if (state.isLoadingHistory) {
      return const ConnectStateView.loading(
        title: 'Loading calls',
        message: 'Please wait while we fetch your call history.',
      );
    }

    if (state.historyErrorMessage != null) {
      return RefreshIndicator(
        onRefresh: () {
          return ref.read(callManagerProvider.notifier).loadCallLogs();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ConnectStateView.error(
                title: 'Could not load calls',
                message: 'Check your internet connection and try again.',
                onAction: () {
                  ref.read(callManagerProvider.notifier).loadCallLogs();
                },
              ),
            ),
          ],
        ),
      );
    }

    final filtered = CallFilterUtils.apply(
      calls: state.callLogs,
      query: _query,
      filter: selectedFilter,
    );

    if (filtered.isEmpty) {
      final hasSearch = _query.trim().isNotEmpty;

      return RefreshIndicator(
        onRefresh: () {
          return ref.read(callManagerProvider.notifier).loadCallLogs();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ConnectStateView.empty(
                icon: hasSearch
                    ? Icons.search_off_rounded
                    : Icons.call_outlined,
                title: hasSearch ? 'No calls found' : 'No calls yet',
                message: hasSearch
                    ? 'Try searching with another name or call type.'
                    : 'Your audio and video call history will appear here.',
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupCalls(filtered);

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(callManagerProvider.notifier).loadCallLogs();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: grouped.entries.map((entry) {
          return _buildSection(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  // -------------------------
  // GROUPING (unchanged)
  // -------------------------
  Map<String, List<CallLog>> _groupCalls(List<CallLog> calls) {
    final Map<String, List<CallLog>> grouped = {};

    for (final call in calls) {
      final title = formatDateGroupTitle(call.createdAt);

      grouped.putIfAbsent(title, () => <CallLog>[]);
      grouped[title]!.add(call);
    }

    return grouped;
  }

  // -------------------------
  // FILTERS (CENTERED like chats)
  // -------------------------
  Widget _buildFilters(CallState state) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip("All", "all"),
          _chip("Missed", "missed"),
          _chip("Incoming", "incoming"),
          _chip("Outgoing", "outgoing"),
          if (state.callLogs.isNotEmpty) ...[
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Clear call history',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: colors.textMuted,
                size: 21,
              ),
              onPressed: _confirmClearCallHistory,
            ),
          ],
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

  // -------------------------
  // SECTION (unchanged)
  // -------------------------
  Widget _buildSection(String title, List<CallLog> calls) {
    if (calls.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            title,
            style: context.pMuted.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
        ),
        ...calls.map(_callTile),
      ],
    );
  }

  // -------------------------
  // TILE
  // -------------------------
  Widget _callTile(CallLog call) {
    final colors = context.appColors;
    final isMissed = call.isMissed;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.border,
        child: Text(call.displayName.isNotEmpty ? call.displayName[0] : "?"),
      ),

      title: Row(
        children: [
          Expanded(
            child: Text(
              call.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMissed ? colors.red : colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (call.isGrouped) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${call.groupCount}',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),

      subtitle: Row(
        children: [
          Icon(
            isMissed
                ? Icons.call_missed
                : call.direction == "incoming"
                ? Icons.call_received
                : Icons.call_made,
            size: 16,
            color: isMissed
                ? colors.red
                : call.direction == "incoming"
                ? colors.success
                : colors.blue,
          ),
          const SizedBox(width: 4),

          Text(call.formattedTime),
          if (call.isGrouped) ...[
            const SizedBox(width: 8),
            Text('${call.groupCount} calls'),
          ],
        ],
      ),

      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
        onSelected: (value) async {
          if (value == 'delete') {
            await _confirmDeleteCall(call);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),

      onTap: () {
        showCallDetailsSheet(context, ref, call);
      },
    );
  }

  Future<void> _confirmDeleteCall(CallLog call) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            call.isGrouped ? 'Delete call group?' : 'Delete call log?',
          ),
          content: Text(
            call.isGrouped
                ? 'This will delete ${call.groupCount} call logs from this group.'
                : 'This will delete this call log from your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _deleteCallLog(call);
  }

  Future<void> _deleteCallLog(CallLog call) async {
    final deleted = await ref
        .read(callManagerProvider.notifier)
        .deleteCallLog(call);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Call log deleted.'
              : 'Could not delete call log. Please try again.',
        ),
      ),
    );
  }

  Future<void> _confirmClearCallHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear call history?'),
          content: const Text(
            'This will remove all call logs from your history. It will not delete them for the other person.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    final cleared = await ref
        .read(callManagerProvider.notifier)
        .clearCallHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleared
              ? 'Call history cleared.'
              : 'Could not clear call history. Please try again.',
        ),
      ),
    );
  }
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;

  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');

  return '$mm:$ss';
}
