import 'package:flutter/material.dart';

class HomePromoItem {
  const HomePromoItem({
    required this.title,
    required this.subtitle,
    this.ctaText = 'Shop Now',
    this.onTapCta,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback? onTapCta;
  final Color color;
  final IconData icon;
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
