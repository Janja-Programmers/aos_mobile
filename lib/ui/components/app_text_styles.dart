import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

extension AppTextStylesX on BuildContext {
  TextStyle get h1 => Theme.of(this).textTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.w800,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get h2 => Theme.of(this).textTheme.headlineSmall!.copyWith(
    fontWeight: FontWeight.w700,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: appColors.textPrimary,
  );

  TextStyle get bodyMuted => Theme.of(this).textTheme.bodyMedium!.copyWith(
    color: appColors.textMuted,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
}
