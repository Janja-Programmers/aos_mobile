import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';

void showCallDetailsSheet(BuildContext context, WidgetRef ref, CallLog call) {
  final colors = context.appColors;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final detailFuture = ref
          .read(callManagerProvider.notifier)
          .loadCallGroupDetail(call);

      return SafeArea(
        top: false,
        child: FutureBuilder<List<CallLog>>(
          future: detailFuture,
          builder: (context, snapshot) {
            final calls = snapshot.data ?? <CallLog>[call];
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Header(call: call),
                    const SizedBox(height: 16),
                    SectionCard(
                      child: Column(
                        children: [
                          _row("Date", DateFormat.yMMMd().format(call.date)),
                          _row("Time", call.formattedTime),
                          _row("Duration", _formatDuration(call.duration)),
                          _row("Type", _type(call)),
                          if (call.isGrouped)
                            _row("Calls", '${call.groupCount}'),
                        ],
                      ),
                    ),
                    if (call.isGrouped) ...[
                      const SizedBox(height: 16),
                      _GroupDetails(
                        calls: calls,
                        isLoading: isLoading,
                        hasError: hasError,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _Actions(sheetContext: sheetContext, ref: ref, call: call),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _Header extends StatelessWidget {
  final CallLog call;

  const _Header({required this.call});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.border,
          child: Text(
            call.displayName.isNotEmpty ? call.displayName[0] : "?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          call.displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _GroupDetails extends StatelessWidget {
  final List<CallLog> calls;
  final bool isLoading;
  final bool hasError;

  const _GroupDetails({
    required this.calls,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (hasError) {
      return Text(
        'Could not load full call history for this group.',
        style: TextStyle(color: context.appColors.textMuted),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Call history',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...calls.map(_groupRow),
        ],
      ),
    );
  }

  Widget _groupRow(CallLog call) {
    return Builder(
      builder: (context) {
        final colors = context.appColors;
        final isMissed = call.isMissed || call.status == 'cancelled';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                isMissed
                    ? Icons.call_missed
                    : call.direction == 'incoming'
                    ? Icons.call_received
                    : Icons.call_made,
                size: 18,
                color: isMissed
                    ? colors.red
                    : call.direction == 'incoming'
                    ? colors.success
                    : colors.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${DateFormat.yMMMd().add_jm().format(call.createdAt)} • ${_type(call)}',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
              Text(
                _formatDuration(call.duration),
                style: TextStyle(color: colors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  final BuildContext sheetContext;
  final WidgetRef ref;
  final CallLog call;

  const _Actions({
    required this.sheetContext,
    required this.ref,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);

                  await AppNavigation.requireAuth(
                    context,
                    ref,
                    onAuthenticated: () async {
                      await ref
                          .read(callStarterServiceProvider)
                          .startOutgoingCall(
                            userId: call.user,
                            callType: AOSCallType.audio,
                            receiver: _participantFromCall(call),
                          );
                    },
                  );
                },
                icon: Icon(Icons.call, color: context.appColors.white),
                label: Text(
                  "Audio Call",
                  style: AppTextStylesX(context).button,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);

                  await AppNavigation.requireAuth(
                    context,
                    ref,
                    onAuthenticated: () async {
                      await ref
                          .read(callStarterServiceProvider)
                          .startOutgoingCall(
                            userId: call.user,
                            callType: AOSCallType.video,
                            receiver: _participantFromCall(call),
                          );
                    },
                  );
                },
                icon: Icon(Icons.video_call, color: context.appColors.white),
                label: Text(
                  "Video Call",
                  style: AppTextStylesX(context).button,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              await _confirmDelete(context);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.appColors.red,
            ),
            label: Text(
              call.isGrouped ? 'Delete call group' : 'Delete call log',
              style: TextStyle(color: context.appColors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

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

    final deleted = await ref
        .read(callManagerProvider.notifier)
        .deleteCallLog(call);

    if (deleted && sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Call log deleted.'
              : 'Could not delete call log. Please try again.',
        ),
      ),
    );
  }
}

CallParticipant _participantFromCall(CallLog call) {
  return CallParticipant(
    userId: call.user,
    displayName: call.displayName.trim().isNotEmpty
        ? call.displayName.trim()
        : call.user,
    avatarUrl: call.avatar,
  );
}

Widget _row(String left, String right) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(fontWeight: FontWeight.w500)),
        Flexible(child: Text(right, textAlign: TextAlign.right)),
      ],
    ),
  );
}

String _type(CallLog call) {
  if (call.isMissed || call.status == 'cancelled') return "Missed";
  return call.direction == "incoming" ? "Incoming" : "Outgoing";
}

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final remainingSeconds = safeSeconds % 60;

  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');

  return '$mm:$ss';
}
