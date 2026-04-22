import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortVisibilityPolicy {
  const ShortVisibilityPolicy();

  bool canShow(Short short) {
    return short.status.isVisible &&
        short.playbackUrl.isNotEmpty &&
        short.thumbnailUrl.isNotEmpty;
  }
}
