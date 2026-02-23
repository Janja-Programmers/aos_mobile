import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

/// Centralized network image widget used across the app
///
/// Handles:
/// - Loading state
/// - Error fallback
/// - Optional border radius
/// - BoxFit consistency
///
/// UI-safe: does NOT impose layout, caller controls size.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return ShimmerBox(
          width: width,
          height: height,
          borderRadius: borderRadius,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image_outlined, size: 20),
        );
      },
    );

    if (borderRadius == null) return image;

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
