import 'dart:math';

import 'package:flutter/foundation.dart';

/// Keeps MapLibre's Android-only native attribution/info control outside the
/// visible map chrome. `maplibre_gl` 0.26.2 hard-enables that native control on
/// Android and does not expose an `attributionEnabled` Dart option.
Point<num>? get aosMapAttributionButtonMargins {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return const Point<num>(-96, -96);
  }
  return null;
}
