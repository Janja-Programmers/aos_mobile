import 'package:flutter/material.dart';

class DashboardHero extends StatelessWidget {
  final ImageProvider? bannerImage;
  final double height;
  final EdgeInsets padding;

  const DashboardHero({
    super.key,
    this.bannerImage,
    this.height = 160,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider effectiveBanner =
        bannerImage ?? const AssetImage('assets/dash.png');

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: effectiveBanner,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
