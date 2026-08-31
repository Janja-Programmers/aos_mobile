import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';

/// Centralized network image widget used across the app.
///
/// Handles loading/error presentation and decodes display-only images close to
/// their rendered size to avoid retaining full-resolution bitmaps in memory.
/// Callers still own layout and semantic context.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingBuilder,
    this.errorBuilder,
    this.gaplessPlayback = false,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) {
    final Widget image = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double? decodeWidth = _resolvedDimension(
          explicit: width,
          constrained: constraints.maxWidth,
        );
        final double? decodeHeight = _resolvedDimension(
          explicit: height,
          constrained: constraints.maxHeight,
        );
        final AppImageDecodeSize decodeSize = AppImageDecode.forBox(
          context,
          logicalWidth: decodeWidth,
          logicalHeight: decodeHeight,
        );

        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: decodeSize.width,
          cacheHeight: decodeSize.height,
          gaplessPlayback: gaplessPlayback,
          loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
          errorBuilder: errorBuilder ?? _defaultErrorBuilder,
        );
      },
    );

    if (borderRadius == null) return image;

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _defaultLoadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    if (progress == null) return child;

    return ShimmerBox(width: width, height: height, borderRadius: borderRadius);
  }

  Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.broken_image_outlined, size: 20),
    );
  }

  static double? _resolvedDimension({
    required double? explicit,
    required double constrained,
  }) {
    if (explicit != null && explicit.isFinite && explicit > 0) {
      return explicit;
    }
    if (constrained.isFinite && constrained > 0) {
      return constrained;
    }
    return null;
  }
}
