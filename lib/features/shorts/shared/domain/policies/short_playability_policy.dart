import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortPlayabilityPolicy {
  const ShortPlayabilityPolicy();

  bool canPlay(Short short) {
    return short.status.isPlayable &&
        short.playbackUrl.isNotEmpty;
  }
}
