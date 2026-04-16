import 'package:flutter/material.dart';

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

        CallControls(callState: callState, manager: manager),

        EndCallSection(onEnd: manager.endCurrentCall),

        const SizedBox(height: 20),
      ],
    );
  }
}
