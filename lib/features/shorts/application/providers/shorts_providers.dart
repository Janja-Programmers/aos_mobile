import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/config/app_config.dart';

// APIs
import 'package:africaonlinestores/features/shorts/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_tracking_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_engagement_api.dart';

// Controllers
import 'package:africaonlinestores/features/shorts/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/application/controllers/short_controller.dart';

// State
import 'package:africaonlinestores/features/shorts/application/state/short_state.dart';
import 'package:africaonlinestores/features/shorts/application/state/upload_state.dart';
import 'package:flutter_riverpod/legacy.dart';

// ─────────────────────────────────────────────
// CORE API CLIENT
// ─────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.normalizedBaseUrl, ref: ref);
});

// ─────────────────────────────────────────────
// API LAYER
// ─────────────────────────────────────────────

final shortsFeedApiProvider = Provider<ShortsFeedApi>((ref) {
  return ShortsFeedApi(ref.read(apiClientProvider));
});

final shortsTrackingApiProvider = Provider<ShortsTrackingApi>((ref) {
  return ShortsTrackingApi(ref.read(apiClientProvider));
});

final shortsManagementApiProvider = Provider<ShortsManagementApi>((ref) {
  return ShortsManagementApi(ref.read(apiClientProvider));
});

final shortsUploadApiProvider = Provider<ShortsUploadApi>((ref) {
  return ShortsUploadApi(ref.read(apiClientProvider));
});

final shortsEngagementApiProvider = Provider<ShortsEngagementApi>((ref) {
  return ShortsEngagementApi(ref.read(apiClientProvider));
});

// ─────────────────────────────────────────────
// CONTROLLERS (THE BRAIN)
// ─────────────────────────────────────────────

final shortsControllerProvider =
    StateNotifierProvider<ShortsController, ShortsState>((ref) {
      return ShortsController(
        ref.read(shortsFeedApiProvider),
        ref.read(shortsTrackingApiProvider),
        ref.read(shortsEngagementApiProvider),
      );
    });

final postShortControllerProvider =
    StateNotifierProvider<PostShortController, UploadState>((ref) {
      return PostShortController(
        uploadApi: ref.read(shortsUploadApiProvider),
        managementApi: ref.read(shortsManagementApiProvider),
      );
    });
