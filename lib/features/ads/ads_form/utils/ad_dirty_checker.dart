import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';

class AdDirtyChecker {
  static bool isDirty(AdDraft d) {
    return d.title.trim().isNotEmpty ||
        (d.locationId ?? '').isNotEmpty ||
        (d.categoryId ?? '').isNotEmpty ||
        d.description.trim().isNotEmpty ||
        d.images.isNotEmpty ||
        d.videoUrl != null ||
        d.attributes.isNotEmpty ||
        d.price != null ||
        (d.priceType ?? '').isNotEmpty;
  }
}
