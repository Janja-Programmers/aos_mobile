import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class CallDecisionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const CallDecisionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reject
        FloatingActionButton(
          heroTag: 'reject_call',
          backgroundColor: colors.primary,
          onPressed: onReject,
          child: Icon(Icons.call_end, color: colors.surface),
        ),

        // Accept
        FloatingActionButton(
          heroTag: 'accept_call',
          backgroundColor: colors.success,
          onPressed: onAccept,
          child: Icon(Icons.call, color: colors.surface),
        ),
      ],
    );
  }
}
