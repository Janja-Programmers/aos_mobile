import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';

extension AppThemeX on BuildContext {
  /// Access your theme tokens (fails loudly if not added to ThemeData.extensions).
  AppColorTokens get appColors => Theme.of(this).extension<AppColorTokens>()!;
}
