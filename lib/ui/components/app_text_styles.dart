import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

extension AppTextStylesX on BuildContext {
  // ---------- Headings ----------

  TextStyle get h1 => Theme.of(this).textTheme.headlineLarge!.copyWith(
    fontWeight: FontWeight.w800,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get h2 => Theme.of(this).textTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.w700,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get h3 => Theme.of(this).textTheme.headlineSmall!.copyWith(
    fontWeight: FontWeight.w700,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  // ---------- Titles (adjusted for more contrast) ----------

  TextStyle get h4 => Theme.of(this).textTheme.titleLarge!.copyWith(
    fontSize: 24, // larger than h5 & h6
    fontWeight: FontWeight.w700,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get h5 => Theme.of(this).textTheme.titleMedium!.copyWith(
    fontSize: 20, // medium
    fontWeight: FontWeight.w600,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get h6 => Theme.of(this).textTheme.titleSmall!.copyWith(
    fontSize: 16, // small
    fontWeight: FontWeight.w500,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  // ---------- Body ----------

  TextStyle get p => Theme.of(this).textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get pMuted => Theme.of(this).textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.w400,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textMuted,
  );

  TextStyle get pStrong => Theme.of(this).textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.w600,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  // ---------- Small / Caption ----------

  TextStyle get small => Theme.of(this).textTheme.bodySmall!.copyWith(
    fontWeight: FontWeight.w500,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get smallMuted => Theme.of(this).textTheme.bodySmall!.copyWith(
    fontWeight: FontWeight.w400,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textMuted,
  );

  TextStyle get caption => Theme.of(this).textTheme.labelSmall!.copyWith(
    fontWeight: FontWeight.w500,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textMuted,
  );

  // ---------- Button ----------

  TextStyle get button => Theme.of(this).textTheme.labelLarge!.copyWith(
    fontWeight: FontWeight.w700,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.btnText,
  );

  // ---------- Overline / Meta ----------

  TextStyle get overline => Theme.of(this).textTheme.labelMedium!.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textMuted,
  );
}
