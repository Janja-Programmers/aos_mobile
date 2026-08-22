import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class ChatMessageStatusIcon extends StatelessWidget {
  const ChatMessageStatusIcon({
    super.key,
    required this.deliveredAt,
    required this.readAt,
    this.size = 14,
    this.sentColor,
    this.deliveredColor,
    this.readColor,
  });

  final DateTime? deliveredAt;
  final DateTime? readAt;
  final double size;
  final Color? sentColor;
  final Color? deliveredColor;
  final Color? readColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (readAt != null) {
      return Icon(Icons.done_all, size: size, color: readColor ?? colors.blue);
    }

    if (deliveredAt != null) {
      return Icon(
        Icons.done_all,
        size: size,
        color: deliveredColor ?? colors.textMuted,
      );
    }

    return Icon(Icons.done, size: size, color: sentColor ?? colors.textMuted);
  }
}
