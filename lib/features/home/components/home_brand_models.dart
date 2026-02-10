import 'package:flutter/material.dart';

class HomePromoItem {
  const HomePromoItem({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    this.onTapCta,
    this.background = const Color(0xFF6F7CF7),
  });

  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback? onTapCta;
  final Color background;
}

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.title,
    required this.icon,
    this.iconBg,
    this.iconFg,
    this.onTapTrailing,
  });

  final String title;
  final IconData icon;
  final Color? iconBg;
  final Color? iconFg;

  /// Only trailing arrow is clickable.
  final VoidCallback? onTapTrailing;
}
