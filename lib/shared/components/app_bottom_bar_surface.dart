import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/layout/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Shared floating surface for global navigation and screen-level actions.
class AppBottomBarSurface extends StatelessWidget {
  const AppBottomBarSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: margin ?? AppDimensions.spacing.bottomNavMargin,
        padding: padding ?? AppDimensions.spacing.bottomNavPadding,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppDimensions.radii.bottomNav,
          boxShadow: AppDimensions.shadows.lg,
        ),
        child: child,
      ),
    );
  }
}
