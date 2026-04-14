import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/utils/format_time.dart';

class PresenceLabel extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;

  const PresenceLabel({super.key, required this.isOnline, this.lastSeen});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (isOnline) {
      return Text(
        "Online",
        style: context.p.copyWith(color: colors.success, fontSize: 12),
      );
    }

    if (lastSeen != null) {
      return Text(
        "Last seen ${formatTime(lastSeen!)}",
        style: context.p.copyWith(fontSize: 12),
      );
    }

    return const SizedBox.shrink();
  }
}
