import 'package:flutter/material.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), action: action, duration: duration),
    );
}
