import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveCallChatBanner extends ConsumerWidget {
  final String conversationId;
  final String otherUserId;
  final String fallbackDisplayName;
  final String? fallbackAvatarUrl;

  const ActiveCallChatBanner({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.fallbackDisplayName,
    this.fallbackAvatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);

    if (!_shouldShowForChat(state)) {
      return const SizedBox.shrink();
    }

    final currentUserId = ref.watch(currentUserProvider);
    final participant = CallParticipantResolver.otherParticipant(
      state,
      currentUserId: currentUserId,
      fallbackName: fallbackDisplayName,
    );

    if (!_matchesThisChat(state, participant.userId)) {
      return const SizedBox.shrink();
    }

    final manager = ref.read(callManagerProvider.notifier);
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final isVideo = state.callMediaMode == CallMediaMode.video;
    final statusText = _statusText(state, l10n);
    final avatarUrl = normalizeMediaUrl(
      participant.avatarUrl ?? fallbackAvatarUrl,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => CallNavigation.toActiveCall(ref),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.success,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: .14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _BannerRoundButton(
                  icon: state.isMuted
                      ? Icons.mic_off_rounded
                      : Icons.mic_none_rounded,
                  tooltip: state.isMuted ? l10n.chat_unmute : l10n.chat_mute,
                  onTap: state.hasActiveRoom ? manager.toggleMute : null,
                ),
                const SizedBox(width: 10),

                _ParticipantAvatar(
                  avatarUrl: avatarUrl,
                  initials: participant.initials,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isVideo
                                ? Icons.videocam_rounded
                                : Icons.call_rounded,
                            color: colors.white.withValues(alpha: .92),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.white.withValues(alpha: .92),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                _BannerRoundButton(
                  icon: Icons.call_end_rounded,
                  tooltip: l10n.chat_end_call,
                  backgroundColor: colors.red,
                  foregroundColor: colors.white,
                  onTap: manager.endCurrentCall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowForChat(CallState state) {
    if (state.activeCall == null) return false;

    switch (state.uiPhase) {
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
      case UiCallPhase.incomingRinging:
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return true;
      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
        return false;
    }
  }

  bool _matchesThisChat(CallState state, String participantUserId) {
    final callConversationId = state.activeCall?.conversationId.trim();
    final currentConversationId = conversationId.trim();

    if (callConversationId != null && callConversationId.isNotEmpty) {
      return _equals(callConversationId, currentConversationId);
    }

    return _equals(participantUserId, otherUserId);
  }

  String _statusText(CallState state, AppLocalizations l10n) {
    if (state.uiPhase == UiCallPhase.inCall && state.hasActiveRoom) {
      return _formatDuration(state.duration);
    }

    switch (state.uiPhase) {
      case UiCallPhase.outgoingStarting:
        return l10n.chat_calling;
      case UiCallPhase.outgoingRinging:
        return l10n.chat_ringing;
      case UiCallPhase.incomingRinging:
        return l10n.chat_incoming_call;
      case UiCallPhase.joiningRoom:
        return l10n.chat_connecting;
      case UiCallPhase.inCall:
        return state.backendStatus == BackendCallStatus.ongoing
            ? _formatDuration(state.duration)
            : l10n.chat_connecting;
      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
        return '';
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _equals(String? a, String? b) {
    final left = a?.trim().toLowerCase();
    final right = b?.trim().toLowerCase();
    if (left == null || left.isEmpty || right == null || right.isEmpty) {
      return false;
    }
    return left == right;
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;

  const _ParticipantAvatar({required this.avatarUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.white.withValues(alpha: .18),
      backgroundImage: hasAvatar
          ? AppImageDecode.networkProvider(
              context,
              avatarUrl!.trim(),
              logicalWidth: 36,
              logicalHeight: 36,
            )
          : null,
      child: hasAvatar
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _BannerRoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _BannerRoundButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                colors.white.withValues(alpha: enabled ? .16 : .08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 21,
            color:
                foregroundColor ??
                colors.white.withValues(alpha: enabled ? 1 : .46),
          ),
        ),
      ),
    );
  }
}
