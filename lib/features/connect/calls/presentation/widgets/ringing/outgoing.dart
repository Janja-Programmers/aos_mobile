import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/widgets/ringing/circle_button.dart';
import 'package:flutter/material.dart';

class OutgoingActions extends StatelessWidget {
  final Future<void> Function() onCancel;

  const OutgoingActions({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: CircleButton(
        icon: Icons.call_end,
        color: colors.red,
        onTap: onCancel,
      ),
    );
  }
}
