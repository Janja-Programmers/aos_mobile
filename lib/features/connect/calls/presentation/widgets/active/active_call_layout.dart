import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/call_main_info.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/top_bar.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/session/call_control_dock.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/video_call_view.dart';

class ActiveCallLayout extends StatelessWidget {
  final CallState callState;
  final CallManager manager;
  final String participant;
  final String subtitle;
  final String initials;

  const ActiveCallLayout({
    super.key,
    required this.callState,
    required this.manager,
    required this.participant,
    required this.subtitle,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final isVideoCall = callState.callMediaMode == CallMediaMode.video;

    return Column(
      children: [
        TopBar(
          isConnected: callState.backendStatus == BackendCallStatus.ongoing,
        ),

        Expanded(
          child: isVideoCall
              ? VideoCallView(room: callState.room)
              : CallMainInfo(
                  participant: participant,
                  subtitle: subtitle,
                  initials: initials,
                  callState: callState,
                ),
        ),

        _VideoUpgradePanel(callState: callState, manager: manager),

        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: CallControlDock(
            isMuted: callState.isMuted,
            isSpeakerOn: callState.isSpeakerOn,
            isVideoCall: isVideoCall,
            isLocalVideoEnabled: callState.isLocalVideoEnabled,
            isWaitingForVideoUpgradeResponse:
                callState.isWaitingForVideoUpgradeResponse,
            hasIncomingVideoUpgradeRequest:
                callState.hasIncomingVideoUpgradeRequest,
            onMore: () {},
            onVideo:
                callState.isWaitingForVideoUpgradeResponse ||
                    callState.hasIncomingVideoUpgradeRequest
                ? null
                : manager.toggleVideo,
            onSpeaker: manager.toggleSpeaker,
            onMute: manager.toggleMute,
            onEnd: manager.endCurrentCall,
          ),
        ),
      ],
    );
  }
}

class _VideoUpgradePanel extends StatelessWidget {
  final CallState callState;
  final CallManager manager;

  const _VideoUpgradePanel({required this.callState, required this.manager});

  @override
  Widget build(BuildContext context) {
    if (callState.hasIncomingVideoUpgradeRequest) {
      return _VideoUpgradeCard(
        title: 'Switch to video call?',
        message: null,
        primaryLabel: 'Switch',
        secondaryLabel: 'Cancel',
        onPrimary: manager.acceptVideoUpgrade,
        onSecondary: manager.declineVideoUpgrade,
        errorMessage: callState.videoUpgradeErrorMessage,
      );
    }

    if (callState.isWaitingForVideoUpgradeResponse) {
      return _VideoUpgradeCard(
        title: 'Video request sent',
        message: 'Waiting for the other person to accept.',
        primaryLabel: null,
        secondaryLabel: null,
        onPrimary: null,
        onSecondary: null,
        errorMessage: callState.videoUpgradeErrorMessage,
      );
    }

    if (callState.videoUpgradeErrorMessage != null) {
      return _VideoUpgradeCard(
        title: 'Video upgrade failed',
        message: callState.videoUpgradeErrorMessage!,
        primaryLabel: null,
        secondaryLabel: null,
        onPrimary: null,
        onSecondary: null,
        errorMessage: null,
      );
    }

    return const SizedBox.shrink();
  }
}

class _VideoUpgradeCard extends StatelessWidget {
  final String title;
  final String? message;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String? errorMessage;

  const _VideoUpgradeCard({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF151C20),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 22,
              offset: Offset(0, 10),
              color: Color(0x66000000),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.white,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.p.copyWith(fontSize: 13, color: Colors.white70),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: context.p.copyWith(fontSize: 12, color: colors.red),
              ),
            ],
            if (primaryLabel != null && secondaryLabel != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(
                      secondaryLabel!,
                      style: TextStyle(color: colors.success),
                    ),
                  ),
                  const SizedBox(width: 18),
                  TextButton(
                    onPressed: onPrimary,
                    child: Text(
                      primaryLabel!,
                      style: TextStyle(color: colors.success),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
