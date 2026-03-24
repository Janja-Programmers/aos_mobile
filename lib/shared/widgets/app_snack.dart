import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

enum SnackState { error, success, info, warning }

enum SnackPosition { top, bottom }

// Default colors for each state
Map<SnackState, Color> _defaultColors = {
  SnackState.error: Colors.orange[300]!,
  SnackState.success: Colors.green[300]!,
  SnackState.info: Colors.blue[300]!,
  SnackState.warning: Colors.white,
};

// Default icons for each state
const Map<SnackState, IconData> _defaultIcons = {
  SnackState.error: Icons.dangerous,
  SnackState.success: Icons.check,
  SnackState.info: Icons.info,
  SnackState.warning: Icons.warning,
};

void showAppSnack(
  BuildContext context,
  String message, {
  SnackState state = SnackState.info,
  SnackPosition position = SnackPosition.bottom,
  Color? color,
  IconData? icon,
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;

  final bgColor = color ?? _defaultColors[state]!;
  final leadingIcon = icon ?? _defaultIcons[state]!;

  // Default top/bottom margins
  final margin = position == SnackPosition.top
      ? const EdgeInsets.fromLTRB(16, 50, 16, 0)
      : const EdgeInsets.fromLTRB(16, 0, 16, 50);

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(leadingIcon, color: context.appColors.border),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: context.pStrong)),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: margin,
      ),
    );
}

/// Fluent helper wrapper
class ShowSnack {
  final BuildContext _context;
  final String _message;

  ShowSnack(this._context, this._message);

  /// Show error snack with default icon & color
  void error({
    IconData? icon,
    Color? color,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppSnack(
      _context,
      _message,
      state: SnackState.error,
      icon: icon,
      color: color,
      action: action,
      duration: duration,
    );
  }

  /// Show success snack with default icon & color
  void success({
    IconData? icon,
    Color? color,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppSnack(
      _context,
      _message,
      state: SnackState.success,
      icon: icon,
      color: color,
      action: action,
      duration: duration,
    );
  }

  /// Optional: info snack
  void info({
    IconData? icon,
    Color? color,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppSnack(
      _context,
      _message,
      state: SnackState.info,
      icon: icon,
      color: color,
      action: action,
      duration: duration,
    );
  }

  /// Optional: warning snack
  void warning({
    IconData? icon,
    Color? color,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    showAppSnack(
      _context,
      _message,
      state: SnackState.warning,
      icon: icon,
      color: color,
      action: action,
      duration: duration,
    );
  }
}
