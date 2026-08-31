import 'dart:io';

import 'package:flutter/widgets.dart';

@immutable
class AppImageDecodeSize {
  const AppImageDecodeSize({this.width, this.height});

  final int? width;
  final int? height;
}

/// Central policy for decoding display-only images close to their rendered size.
///
/// The policy intentionally selects only one decode axis so the source aspect
/// ratio is preserved by Flutter's image codec. Upload/crop source files are
/// never modified by this class.
abstract final class AppImageDecode {
  static const int maxThumbnailPixels = 2048;

  static AppImageDecodeSize forBox(
    BuildContext context, {
    double? logicalWidth,
    double? logicalHeight,
    int maxPixels = maxThumbnailPixels,
  }) {
    assert(maxPixels > 0, 'maxPixels must be greater than zero.');

    final double? width = _finitePositive(logicalWidth);
    final double? height = _finitePositive(logicalHeight);

    if (width == null && height == null) {
      return const AppImageDecodeSize();
    }

    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    if (height != null && (width == null || height > width)) {
      return AppImageDecodeSize(
        height: _toPhysicalPixels(height, devicePixelRatio, maxPixels),
      );
    }

    return AppImageDecodeSize(
      width: _toPhysicalPixels(width!, devicePixelRatio, maxPixels),
    );
  }

  static ImageProvider<Object> resizeProvider(
    BuildContext context,
    ImageProvider<Object> provider, {
    double? logicalWidth,
    double? logicalHeight,
    int maxPixels = maxThumbnailPixels,
  }) {
    final AppImageDecodeSize size = forBox(
      context,
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      maxPixels: maxPixels,
    );

    return ResizeImage.resizeIfNeeded(size.width, size.height, provider);
  }

  static ImageProvider<Object> networkProvider(
    BuildContext context,
    String url, {
    double? logicalWidth,
    double? logicalHeight,
    int maxPixels = maxThumbnailPixels,
  }) {
    return resizeProvider(
      context,
      NetworkImage(url),
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      maxPixels: maxPixels,
    );
  }

  static ImageProvider<Object> networkProviderForPixels(
    String url, {
    int? width,
    int? height,
  }) {
    assert(
      (width != null && width > 0) || (height != null && height > 0),
      'A positive width or height is required.',
    );

    return ResizeImage.resizeIfNeeded(width, height, NetworkImage(url));
  }

  static ImageProvider<Object> fileProvider(
    BuildContext context,
    File file, {
    double? logicalWidth,
    double? logicalHeight,
    int maxPixels = maxThumbnailPixels,
  }) {
    return resizeProvider(
      context,
      FileImage(file),
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      maxPixels: maxPixels,
    );
  }

  static double? _finitePositive(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  static int _toPhysicalPixels(
    double logicalPixels,
    double devicePixelRatio,
    int maxPixels,
  ) {
    final int pixels = (logicalPixels * devicePixelRatio).ceil();
    if (pixels < 1) return 1;
    if (pixels > maxPixels) return maxPixels;
    return pixels;
  }
}
