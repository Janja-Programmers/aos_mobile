import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class DsTypography {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  /// 32 / w700
  static TextStyle display(BuildContext context) => _base(
    size: 32,
    weight: FontWeight.w700,
    color: context.appColors.textPrimary,
  );

  /// 24 / w700
  static TextStyle headline(BuildContext context) => _base(
    size: 24,
    weight: FontWeight.w700,
    color: context.appColors.textPrimary,
  );

  /// 18 / w600
  static TextStyle title(BuildContext context) => _base(
    size: 18,
    weight: FontWeight.w600,
    color: context.appColors.textPrimary,
  );

  /// 16 / w600
  static TextStyle subtitle(BuildContext context) => _base(
    size: 16,
    weight: FontWeight.w600,
    color: context.appColors.textPrimary,
  );

  /// 14 / w400
  static TextStyle body(BuildContext context) => _base(
    size: 14,
    weight: FontWeight.w400,
    color: context.appColors.textPrimary,
  );

  /// 14 / w600
  static TextStyle bodyStrong(BuildContext context) => _base(
    size: 14,
    weight: FontWeight.w600,
    color: context.appColors.textPrimary,
  );

  /// 12 / w500
  static TextStyle caption(BuildContext context) => _base(
    size: 12,
    weight: FontWeight.w500,
    color: context.appColors.textPrimary.withOpacity(0.67),
  );

  /// 16 / w600
  static TextStyle button(BuildContext context) =>
      _base(size: 16, weight: FontWeight.w600, color: Colors.white);

  /// 13 / w500
  static TextStyle chip(BuildContext context) => _base(
    size: 13,
    weight: FontWeight.w500,
    color: context.appColors.textPrimary,
  );
}
