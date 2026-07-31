import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

abstract final class AosShareLinks {
  static Uri live(String liveId) {
    final normalizedLiveId = liveId.trim();
    if (normalizedLiveId.isEmpty) {
      throw ArgumentError.value(liveId, 'liveId', 'Must not be empty.');
    }

    return Uri(
      scheme: 'aos',
      host: 'open',
      path: AppRoutes.liveRoom,
      queryParameters: <String, String>{'live_id': normalizedLiveId},
    );
  }
}
