import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_filter_utils.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/show_call_details_sheet.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_state_view.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;
  final bool hideFilters;

  const CallListScreen({super.key, this.searchQuery, this.hideFilters = false});

  @override
  ConsumerState<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends ConsumerState<CallListScreen>
    with WidgetsBindingObserver {
  String selectedFilter = 'all';
  String _query = '';
  bool? _canUseFullScreenIntent;
  bool _isOpeningFullScreenIntentSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _query = widget.searchQuery ?? '';

    // Riverpod 3 rejects provider mutations while the widget tree is mounting.
    // Defer history loading until the first frame has completed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_initializeScreen());
    });
  }

  Future<void> _initializeScreen() async {
    appLogger.i('📞 Calls screen initialization started');

    try {
      await ref.read(callManagerProvider.notifier).loadCallLogs();
      if (!mounted) return;

      await _refreshFullScreenIntentStatus();
      appLogger.i('📞 Calls screen initialization completed');
    } catch (error, stackTrace) {
      appLogger.e(
        '📞 Calls screen initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshFullScreenIntentStatus());
    }
  }

  Future<void> _refreshFullScreenIntentStatus() async {
    if (!Platform.isAndroid) return;

    final allowed = await ref
        .read(callKitServiceProvider)
        .canUseFullScreenIntent();
    if (!mounted || _canUseFullScreenIntent == allowed) return;

    setState(() {
      _canUseFullScreenIntent = allowed;
    });
  }

  Future<void> _requestFullScreenIntentPermission() async {
    if (_isOpeningFullScreenIntentSettings) return;

    setState(() {
      _isOpeningFullScreenIntentSettings = true;
    });

    try {
      await ref
          .read(callKitServiceProvider)
          .requestFullScreenIntentPermission();
      await _refreshFullScreenIntentStatus();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningFullScreenIntentSettings = false;
        });
      }
    }
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
        if (_canUseFullScreenIntent == false) _buildFullScreenIntentBanner(),
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

  Widget _buildFullScreenIntentBanner() {
    final colors = context.appColors;

    return Semantics(
      container: true,
      label: 'Full-screen incoming calls are disabled',
      child: Material(
        color: colors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_in_talk_outlined, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enable full-screen incoming calls',
                      style: context.pStrong,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Android may otherwise show only a heads-up call '
                'notification.',
                style: context.smallMuted,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _isOpeningFullScreenIntentSettings
                      ? null
                      : _requestFullScreenIntentPermission,
                  child: _isOpeningFullScreenIntentSettings
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Open settings'),
                ),
              ),
            ],
          ),
        ),
      ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chip('All', 'all'),
                  _chip('Missed', 'missed'),
                  _chip('Incoming', 'incoming'),
                  _chip('Outgoing', 'outgoing'),
                  if (state.callLogs.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    IconButton(
                      tooltip: 'Clear call history',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value) {
    final colors = context.appColors;
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    final direction = call.direction.trim().toLowerCase();
    final status = call.status.trim().toLowerCase();

    final isMissed =
        call.isMissed ||
        status == 'missed' ||
        (direction == 'incoming' && status == 'cancelled');

    return ListTile(
      leading: _CallHistoryAvatar(call: call),

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
                color: colors.primary.withValues(alpha: 0.1),
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
                ? Icons.phone_missed
                : call.direction == 'incoming'
                ? Icons.call_received
                : Icons.call_made,
            size: 16,
            color: isMissed
                ? colors.red
                : call.direction == 'incoming'
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
          backgroundColor: context.appColors.surface,
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

class _CallHistoryAvatar extends StatelessWidget {
  final CallLog call;

  const _CallHistoryAvatar({required this.call});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatar = call.avatar?.trim();
    final initial = call.displayName.trim().isNotEmpty
        ? call.displayName.trim().substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      backgroundColor: colors.border,
      backgroundImage: avatar != null && avatar.isNotEmpty
          ? NetworkImage(avatar)
          : null,
      child: avatar == null || avatar.isEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
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
