import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.grey;
  static const Color tertiary = Colors.white;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color success = Color(0xFF2E7D32); // Or use Colors.green[700]
  static const Color danger = Colors.red;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static final Color shadow = AppColors.black.withAlpha(
    (0.1 * 255).toInt(),
  ); // Equivalent to 10% opacity black
}
