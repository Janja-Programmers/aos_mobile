import 'package:flutter/material.dart';
import 'package:aos_mobile/core/theme/app_theme_extensions.dart';

extension AppTextStylesX on BuildContext {
  TextStyle get h1 => Theme.of(this).textTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.w800,
    color: appColors.text,
  );

  TextStyle get h2 => Theme.of(this).textTheme.headlineSmall!.copyWith(
    fontWeight: FontWeight.w700,
    color: appColors.text,
  );

  TextStyle get bodyMuted =>
      Theme.of(this).textTheme.bodyMedium!.copyWith(color: appColors.muted);
}
