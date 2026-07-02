import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/circle_button.dart';
import 'package:flutter/material.dart';

class IncomingActions extends StatelessWidget {
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const IncomingActions({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleButton(
            icon: Icons.call_end,
            color: colors.red,
            onTap: onReject,
          ),
          CircleButton(
            icon: Icons.call,
            color: colors.success,
            onTap: onAccept,
          ),
        ],
      ),
    );
  }
}
