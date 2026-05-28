import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/call_controls.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/call_main_info.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/end_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/active/top_bar.dart';
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

        CallControls(callState: callState, manager: manager),

        EndCallSection(onEnd: manager.endCurrentCall),

        const SizedBox(height: 20),
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
        title: 'Switch to video?',
        message:
            'The other person wants to turn this audio call into a video call.',
        primaryLabel: 'Accept',
        secondaryLabel: 'Decline',
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
  final String message;
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
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
              color: colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.p.copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
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
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    child: Text(secondaryLabel!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    child: Text(primaryLabel!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
