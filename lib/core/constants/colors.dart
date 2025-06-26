import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color red = Color.fromARGB(156, 192, 33, 33);
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
  static const Color cardColor = Colors.white;
  static const Color borderColor = Colors.grey;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.amber;
  static const Color info = Colors.blueAccent;
  static const Color light = Colors.lightBlueAccent;
  static const Color dark = Colors.blueGrey;
  static const Color background = Color.fromARGB(255, 233, 227, 227);
  static const Color transparent = Colors.transparent;
  static const Color disabled = Colors.grey;
  static const Color highlight = Colors.yellow;
  static const Color overlay = Color(0x80000000); // Semi-transparent black
  static const Color accent = Colors.pinkAccent;
  static const Color divider = Colors.grey;
}
