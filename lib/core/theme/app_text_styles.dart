import 'package:africaonlinestores/core/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

TextStyle _base({
  required double size,
  required FontWeight weight,
  required Color color,
  double? height,
}) {
  return GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

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

extension AppTextStylesY on BuildContext {
  // ---------- App / Global ----------

  TextStyle get appTitle =>
      _base(size: 20, weight: FontWeight.w700, color: appColors.textPrimary);

  TextStyle get sectionHeader =>
      _base(size: 18, weight: FontWeight.w700, color: appColors.textPrimary);

  TextStyle get sectionHeaderTinted =>
      _base(size: 16, weight: FontWeight.w700, color: appColors.primaryRedSoft);

  TextStyle get seeAll =>
      _base(size: 14, weight: FontWeight.w500, color: appColors.primary);

  // ---------- Auth ----------

  TextStyle get authTitle =>
      _base(size: 26, weight: FontWeight.w600, color: appColors.textPrimary);

  TextStyle get authSubtitle =>
      _base(size: 15, weight: FontWeight.w400, color: appColors.textSecondary);

  // ---------- Forms ----------

  TextStyle get formLabel =>
      _base(size: 14, weight: FontWeight.w500, color: appColors.textPrimary);

  TextStyle get formValue =>
      _base(size: 15, weight: FontWeight.w400, color: appColors.textPrimary);

  TextStyle formHint({bool auth = false}) => _base(
    size: auth ? 15 : 14,
    weight: FontWeight.w400,
    color: appColors.textMuted,
  );

  // ---------- Product Cards ----------

  TextStyle get productTitle =>
      _base(size: 16, weight: FontWeight.w600, color: appColors.textPrimary);

  TextStyle productLocation({bool compact = false}) => _base(
    size: compact ? 12 : 13,
    weight: FontWeight.w400,
    color: appColors.textSecondary,
  );

  TextStyle get productPrice =>
      _base(size: 16, weight: FontWeight.w700, color: appColors.textPrimary);

  TextStyle get productListPrice =>
      _base(size: 15, weight: FontWeight.w700, color: appColors.primary);

  // ---------- Meta ----------

  TextStyle get ratingCount =>
      _base(size: 12, weight: FontWeight.w400, color: appColors.textMuted);

  TextStyle get errorText =>
      _base(size: 13, weight: FontWeight.w400, color: Colors.red);

  // ---------- Navigation ----------

  TextStyle bottomNavLabel({required bool selected}) => _base(
    size: 12,
    weight: selected ? FontWeight.w700 : FontWeight.w500,
    color: selected ? appColors.primary : appColors.textPrimary,
  );

  // ---------- Carousel ----------

  TextStyle get carouselTitle =>
      _base(size: 22, weight: FontWeight.w800, color: Colors.white);

  TextStyle get carouselSubtitle => _base(
    size: 14,
    weight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
  );

  TextStyle get carouselDescription => _base(
    size: 12,
    weight: FontWeight.w400,
    color: Colors.white.withOpacity(0.7),
  );
}

extension DsTypographyX on BuildContext {
  TextStyle get display => DsTypography.display(this);
  TextStyle get headline => DsTypography.headline(this);
  TextStyle get title => DsTypography.title(this);
  TextStyle get subtitle => DsTypography.subtitle(this);
  TextStyle get body => DsTypography.body(this);
  TextStyle get bodyStrong => DsTypography.bodyStrong(this);
  TextStyle get caption => DsTypography.caption(this);
  TextStyle get button => DsTypography.button(this);
  TextStyle get chip => DsTypography.chip(this);
}
