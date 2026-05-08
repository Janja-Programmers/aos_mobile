import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class MiniMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isActive;

  /// Allows reuse in normal row metrics and white overlay metrics.
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final Axis direction;
  final double spacing;
  final List<Shadow>? shadows;

  const MiniMetric({
    super.key,
    required this.icon,
    required this.value,
    this.isActive = false,
    this.iconColor,
    this.textColor,
    this.iconSize = 14,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w700,
    this.direction = Axis.horizontal,
    this.spacing = 3,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final resolvedColor = isActive ? colors.primary : colors.textMuted;
    final resolvedIconColor = iconColor ?? resolvedColor;
    final resolvedTextColor = textColor ?? resolvedColor;

    final iconWidget = Icon(
      icon,
      size: iconSize,
      color: resolvedIconColor,
      shadows: shadows,
    );

    final textWidget = Text(
      value,
      style: context.small.copyWith(
        color: resolvedTextColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        shadows: shadows,
      ),
    );

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          SizedBox(height: spacing),
          textWidget,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        SizedBox(width: spacing),
        textWidget,
      ],
    );
  }
}
