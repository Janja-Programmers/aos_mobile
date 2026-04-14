import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/widgets/incoming_call/call_avatar.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/incoming_call/call_decision_buttons.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/incoming_call/call_info.dart';

class IncomingCallView extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallView({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            CallAvatar(avatarUrl: avatarUrl, fallback: name),

            const SizedBox(height: 42),

            CallInfo(name: name, subtitle: 'Incoming call...'),

            const Spacer(flex: 3),

            CallDecisionButtons(onAccept: onAccept, onReject: onReject),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
