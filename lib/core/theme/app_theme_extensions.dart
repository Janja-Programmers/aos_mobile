import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

extension AppThemeX on BuildContext {
  /// Access your theme tokens (fails loudly if not added to ThemeData.extensions).
  AppColorTokens get appColors => Theme.of(this).extension<AppColorTokens>()!;
}
