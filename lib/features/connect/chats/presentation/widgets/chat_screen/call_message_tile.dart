import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';

class CallMessageTile extends ConsumerWidget {
  final ChatMessage message;
  final bool isMe;
  final String conversationId;
  final String otherUserId;
  final String otherDisplayName;
  final String? otherAvatarUrl;

  const CallMessageTile({
    super.key,
    required this.message,
    required this.isMe,
    required this.conversationId,
    required this.otherUserId,
    required this.otherDisplayName,
    this.otherAvatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final callState = ref.watch(callManagerProvider);

    final isVideo = _isVideoCall(message);
    final activeForThisMessage = _isActiveForThisMessage(callState);
    final status = _normalizedStatus(message);
    final missed = _isMissed(status, message);
    final noAnswer = _isNoAnswer(status, message);
    final failedLike =
        missed || noAnswer || _isRejected(status) || _isCancelled(status);

    final title = missed
        ? 'Missed ${isVideo ? 'video' : 'voice'} call'
        : '${isVideo ? 'Video' : 'Voice'} call';

    final subtitle = activeForThisMessage
        ? 'In call · Tap to return'
        : _subtitle(
            status: status,
            message: message,
            missed: missed,
            noAnswer: noAnswer,
          );

    final icon = missed || noAnswer
        ? Icons.call_missed_rounded
        : isVideo
        ? Icons.videocam_rounded
        : Icons.call_rounded;

    final iconColor = failedLike ? colors.red : colors.success;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleTap(
              context: context,
              ref: ref,
              isVideo: isVideo,
              activeForThisMessage: activeForThisMessage,
              missedOrNoAnswer: missed || noAnswer,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 292, minWidth: 210),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? colors.chatCardColor : colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: failedLike
                      ? colors.red.withOpacity(.18)
                      : colors.border.withOpacity(.75),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe ? colors.white : colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe
                                ? colors.white.withOpacity(.78)
                                : failedLike
                                ? colors.red
                                : colors.textMuted,
                            fontWeight: missed || noAnswer
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activeForThisMessage || missed || noAnswer) ...[
                    const SizedBox(width: 8),
                    Icon(
                      activeForThisMessage
                          ? Icons.open_in_full_rounded
                          : Icons.call_rounded,
                      color: iconColor,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isActiveForThisMessage(CallState state) {
    final call = state.activeCall;
    if (call == null) return false;

    switch (state.uiPhase) {
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
      case UiCallPhase.incomingRinging:
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        break;
      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
        return false;
    }

    final messageCallId = message.callId?.trim().toLowerCase();
    if (messageCallId != null && messageCallId.isNotEmpty) {
      return call.id.trim().toLowerCase() == messageCallId;
    }

    return call.conversationId.trim().toLowerCase() ==
        conversationId.trim().toLowerCase();
  }

  Future<void> _handleTap({
    required BuildContext context,
    required WidgetRef ref,
    required bool isVideo,
    required bool activeForThisMessage,
    required bool missedOrNoAnswer,
  }) async {
    if (activeForThisMessage) {
      CallNavigation.toActiveCall(ref);
      return;
    }

    if (!missedOrNoAnswer) return;

    final userId = otherUserId.trim();
    if (userId.isEmpty) return;

    await ref
        .read(callStarterServiceProvider)
        .startOutgoingCall(
          userId: userId,
          callType: isVideo ? AOSCallType.video : AOSCallType.audio,
          receiver: CallParticipant(
            userId: userId,
            displayName: otherDisplayName,
            avatarUrl: otherAvatarUrl,
          ),
        );
  }

  String _subtitle({
    required String status,
    required ChatMessage message,
    required bool missed,
    required bool noAnswer,
  }) {
    if (missed) return 'Tap to call back';
    if (noAnswer) return 'No answer';
    if (_isRejected(status)) return 'Declined';
    if (_isCancelled(status)) return 'Cancelled';
    if (status == 'ringing' || _text(message).contains('ringing')) {
      return 'Ringing';
    }
    if (status == 'initiated' || status == 'calling') return 'Calling';
    if (status == 'ongoing') return 'In call';

    final duration = message.callDurationSeconds;
    if (duration != null && duration > 0) {
      return _formatCallDuration(duration);
    }

    final parsedDuration = _durationFromText(_text(message));
    if (parsedDuration != null && parsedDuration > 0) {
      return _formatCallDuration(parsedDuration);
    }

    final clean = message.visibleText.trim();
    if (clean.isNotEmpty && clean.length <= 42) return clean;

    return 'Call';
  }

  bool _isVideoCall(ChatMessage message) {
    final type = (message.callType ?? '').trim().toLowerCase();
    final text = _text(message);
    return type == 'video' || text.contains('video') || text.contains('🎥');
  }

  String _normalizedStatus(ChatMessage message) {
    final status = (message.callStatus ?? '').trim().toLowerCase();
    if (status.isNotEmpty) return status;

    final text = _text(message);
    if (text.contains('no answer') || text.contains('not answered')) {
      return 'no_answer';
    }
    if (text.contains('missed')) return 'missed';
    if (text.contains('rejected') || text.contains('declined')) {
      return 'rejected';
    }
    if (text.contains('cancelled') || text.contains('canceled')) {
      return 'cancelled';
    }
    if (text.contains('ringing')) return 'ringing';
    if (text.contains('calling')) return 'calling';
    if (text.contains('ended')) return 'ended';

    return '';
  }

  bool _isMissed(String status, ChatMessage message) {
    final text = _text(message);
    return status == 'missed' || text.contains('missed');
  }

  bool _isNoAnswer(String status, ChatMessage message) {
    final text = _text(message);
    return status == 'no_answer' ||
        status == 'not_answered' ||
        text.contains('no answer') ||
        text.contains('not answered');
  }

  bool _isRejected(String status) {
    return status == 'rejected' || status == 'declined';
  }

  bool _isCancelled(String status) {
    return status == 'cancelled' || status == 'canceled';
  }

  String _text(ChatMessage message) {
    return message.visibleText.trim().toLowerCase();
  }

  int? _durationFromText(String text) {
    final secsMatch = RegExp(
      r'(\d+)\s*(sec|secs|second|seconds)',
    ).firstMatch(text);
    if (secsMatch != null) return int.tryParse(secsMatch.group(1) ?? '');

    final minsMatch = RegExp(
      r'(\d+)\s*(min|mins|minute|minutes)',
    ).firstMatch(text);
    if (minsMatch != null) {
      final minutes = int.tryParse(minsMatch.group(1) ?? '');
      if (minutes != null) return minutes * 60;
    }

    final clockMatch = RegExp(
      r'\b(\d{1,2}):(\d{2})(?::(\d{2}))?\b',
    ).firstMatch(text);
    if (clockMatch == null) return null;

    final first = int.tryParse(clockMatch.group(1) ?? '0') ?? 0;
    final second = int.tryParse(clockMatch.group(2) ?? '0') ?? 0;
    final thirdRaw = clockMatch.group(3);

    if (thirdRaw == null) {
      return (first * 60) + second;
    }

    final third = int.tryParse(thirdRaw) ?? 0;
    return (first * 3600) + (second * 60) + third;
  }

  String _formatCallDuration(int seconds) {
    if (seconds < 60) return '$seconds secs';

    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
