import 'dart:async';

import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:go_router/go_router.dart';

class GoRouterProtectedNavigationExecutor
    implements ProtectedNavigationExecutor {
  const GoRouterProtectedNavigationExecutor({
    required GoRouter router,
    required LiveManager liveManager,
    required AdsApi adsApi,
  }) : _router = router,
       _liveManager = liveManager,
       _adsApi = adsApi;

  final GoRouter _router;
  final LiveManager _liveManager;
  final AdsApi _adsApi;

  @override
  void execute(ProtectedNavigationDestination destination) {
    switch (destination.kind) {
      case ProtectedNavigationKind.messages:
        final String? conversationId = destination.canonicalId;
        if (conversationId == null) {
          _router
              .pushNamed<void>(
                AppRoutes.nConnect,
                queryParameters: const <String, String>{'tab': 'messages'},
              )
              .ignore();
          return;
        }
        _router
            .pushNamed<void>(
              AppRoutes.nMessages,
              pathParameters: <String, String>{
                'conversationId': conversationId,
              },
              extra: <String, Object?>{
                'otherUser': destination.otherUser ?? '',
                'displayName': destination.displayName ?? '',
                'otherUserAvatar': destination.avatarUrl,
              },
            )
            .ignore();
        return;
      case ProtectedNavigationKind.calls:
        _router
            .pushNamed<void>(
              AppRoutes.nConnect,
              queryParameters: const <String, String>{'tab': 'calls'},
            )
            .ignore();
        return;
      case ProtectedNavigationKind.profile:
        _router
            .pushNamed<void>(
              AppRoutes.nProfile,
              queryParameters: <String, String>{
                'user': destination.canonicalId!,
              },
            )
            .ignore();
        return;
      case ProtectedNavigationKind.adDetails:
        unawaited(_openAdDetailsIfAvailable(destination.canonicalId!));
        return;
      case ProtectedNavigationKind.account:
        _router.pushNamed<void>(AppRoutes.nAccount).ignore();
        return;
      case ProtectedNavigationKind.sellerVerification:
        _router.pushNamed<void>(AppRoutes.nSellerVerification).ignore();
        return;
      case ProtectedNavigationKind.live:
        unawaited(_joinLiveWithFallback(destination.canonicalId!));
        return;
      case ProtectedNavigationKind.shortDetails:
        _router
            .pushNamed<void>(
              AppRoutes.nShortDetail,
              queryParameters: <String, String>{
                'short_id': destination.canonicalId!,
              },
            )
            .ignore();
        return;
      case ProtectedNavigationKind.notifications:
        _router.goNamed(AppRoutes.nNotification);
        return;
      case ProtectedNavigationKind.feeds:
        _router.pushNamed<void>(AppRoutes.nFeeds).ignore();
        return;
      case ProtectedNavigationKind.myAds:
        _router.goNamed(AppRoutes.nMyAds);
        return;
    }
  }

  Future<void> _openAdDetailsIfAvailable(String adId) async {
    final result = await _adsApi.getAd(adId: adId);
    if (result.isLeft) {
      appLogger.w(
        'Notification target ad is unavailable; returning to Notification Center '
        '(adId=$adId, error=${result.leftOrNull?.error ?? 'unknown'})',
      );
      _router.goNamed(AppRoutes.nNotification);
      return;
    }
    _router
        .pushNamed<void>(
          AppRoutes.nAdDetails,
          pathParameters: <String, String>{'id': adId},
        )
        .ignore();
  }

  Future<void> _joinLiveWithFallback(String liveId) async {
    try {
      final bool joined = await _liveManager.joinLive(liveId: liveId);
      if (!joined) _openLiveRoute(liveId);
    } catch (error, stackTrace) {
      appLogger.w(
        'Live manager navigation failed; using the live route',
        error: error,
        stackTrace: stackTrace,
      );
      _openLiveRoute(liveId);
    }
  }

  void _openLiveRoute(String liveId) {
    _router
        .pushNamed<void>(
          AppRoutes.nLiveRoom,
          queryParameters: <String, String>{'live_id': liveId},
        )
        .ignore();
  }
}
