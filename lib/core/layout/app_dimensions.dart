import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  static const spacing = _DsSpacing();
  static const radii = _DsRadii();
  static const shadows = _DsShadows();
  static const sizes = _DsSizes();
}

class _DsSpacing {
  const _DsSpacing();

  // Base scale
  double get xxs => 2;
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 20;
  double get xxl => 24;
  double get xxxl => 32;
  double get jumbo => 40;

  // Common paddings
  EdgeInsets get pageHorizontal => const EdgeInsets.symmetric(horizontal: 20);
  EdgeInsets get pageHorizontalAuth =>
      const EdgeInsets.symmetric(horizontal: 26);
  EdgeInsets get cardGrid => const EdgeInsets.all(10);
  EdgeInsets get cardList => const EdgeInsets.all(12);
  EdgeInsets get bottomNavMargin => const EdgeInsets.fromLTRB(12, 0, 12, 12);
  EdgeInsets get bottomNavPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  EdgeInsets get searchBar =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  EdgeInsets get searchBarHome =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
}

class _DsRadii {
  const _DsRadii();

  // Radius values
  double get xxs => 4;
  double get xs => 6;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 20;
  double get xxl => 24;
  double get pill => 999;

  // Common BorderRadius
  BorderRadius get r8 => BorderRadius.circular(8);
  BorderRadius get r12 => BorderRadius.circular(12);
  BorderRadius get r16 => BorderRadius.circular(16);
  BorderRadius get r20 => BorderRadius.circular(20);
  BorderRadius get r24 => BorderRadius.circular(24);

  // Specific components
  BorderRadius get adCard => r12;
  BorderRadius get carousel => r16;
  BorderRadius get bottomNav => r20;
  BorderRadius get dialog => r20;

  BorderRadius get bottomSheetTop =>
      const BorderRadius.vertical(top: Radius.circular(20));

  BorderRadius get pillRadius => BorderRadius.circular(pill);
}

class _DsShadows {
  const _DsShadows();

  List<BoxShadow> get sm => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  List<BoxShadow> get md => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  List<BoxShadow> get lg => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // Inline variants
  List<BoxShadow> sellButton(Color primaryRed) => [
    BoxShadow(
      color: primaryRed.withValues(alpha: 0.23),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}

class _DsSizes {
  const _DsSizes();

  // Icons
  double get iconSm => 16;
  double get iconMd => 20;
  double get iconLg => 24;

  // Buttons
  double get buttonHeightSm => 40;
  double get buttonHeightMd => 48;
  double get buttonHeightLg => 56;

  // Inputs
  double get inputHeight => 48;
}
