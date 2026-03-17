import 'package:africaonlinestores/shared/enums/ads.dart';

class AdEditPolicy {
  const AdEditPolicy._();

  /// Title can only change while the ad is not active
  static bool canEditTitle(AdStatus? status) {
    if (status == null) return true;

    switch (status) {
      case AdStatus.reviewing:
      case AdStatus.declined:
        return true;

      case AdStatus.active:
        return false;
    }
  }
}
