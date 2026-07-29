import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

class NotificationDestinationParser {
  const NotificationDestinationParser();

  ProtectedNavigationDestination? parse({
    required NotificationType type,
    required NotificationPayload payload,
  }) {
    switch (type) {
      case NotificationType.message:
        final String? conversationId = _safeIdentifier(
          payload.conversationId,
        );
        if (conversationId == null) {
          return const ProtectedNavigationDestination(
            kind: ProtectedNavigationKind.messages,
          );
        }
        return ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.messages,
          canonicalId: conversationId,
          otherUser: _safeIdentifier(payload.otherUser ?? payload.userId),
          displayName: _safeDisplayText(
            payload.actorName ?? payload.otherUserName,
          ),
          avatarUrl: _safeMediaUrl(payload.actorAvatar),
        );
      case NotificationType.missedCall:
      case NotificationType.callRejected:
      case NotificationType.callEnded:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.calls,
        );
      case NotificationType.incomingCall:
        return null;
      case NotificationType.follow:
        final String? userId = _safeIdentifier(payload.userId);
        return userId == null
            ? const ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.notifications,
              )
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.profile,
                canonicalId: userId,
              );
      case NotificationType.adApproved:
      case NotificationType.adRejected:
      case NotificationType.adExpired:
        final String? adId = _safeIdentifier(payload.adId);
        return adId == null
            ? const ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.myAds,
              )
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.adDetails,
                canonicalId: adId,
              );
      case NotificationType.verificationApproved:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.account,
        );
      case NotificationType.verificationRejected:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.sellerVerification,
        );
      case NotificationType.liveStarted:
        final String? liveId = _safeIdentifier(payload.liveId);
        return liveId == null
            ? const ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.feeds,
              )
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.live,
                canonicalId: liveId,
              );
      case NotificationType.newShort:
      case NotificationType.shortLike:
      case NotificationType.shortComment:
      case NotificationType.commentReply:
        final String? shortId = _safeIdentifier(
          payload.shortId ?? _readShortIdFromRoute(payload.route),
        );
        return shortId == null
            ? const ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.feeds,
              )
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.shortDetails,
                canonicalId: shortId,
              );
      case NotificationType.unknown:
        final String? route = _clean(payload.route);
        if (route == null) {
          return const ProtectedNavigationDestination(
            kind: ProtectedNavigationKind.notifications,
          );
        }
        return _fromValidatedRoute(route);
    }
  }

  ProtectedNavigationDestination? _fromValidatedRoute(String? route) {
    final String? cleanRoute = _clean(route);
    if (cleanRoute == null ||
        !cleanRoute.startsWith('/') ||
        cleanRoute.startsWith('//')) {
      return null;
    }

    final Uri? uri = Uri.tryParse(cleanRoute);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.fragment.isNotEmpty ||
        uri.pathSegments.any((String segment) => segment == '..')) {
      return null;
    }

    switch (uri.path) {
      case AppRoutes.notification:
      case AppRoutes.notifications:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.notifications,
        );
      case AppRoutes.account:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.account,
        );
      case AppRoutes.sellerVerification:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.sellerVerification,
        );
      case AppRoutes.myAds:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.myAds,
        );
      case AppRoutes.feeds:
        return const ProtectedNavigationDestination(
          kind: ProtectedNavigationKind.feeds,
        );
      case AppRoutes.connect:
        final String? tab = _clean(uri.queryParameters['tab']);
        if (tab == null || tab == 'messages') {
          return const ProtectedNavigationDestination(
            kind: ProtectedNavigationKind.messages,
          );
        }
        if (tab == 'calls') {
          return const ProtectedNavigationDestination(
            kind: ProtectedNavigationKind.calls,
          );
        }
        return null;
      case AppRoutes.profile:
        final String? userId = _safeIdentifier(uri.queryParameters['user']);
        return userId == null
            ? null
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.profile,
                canonicalId: userId,
              );
      case AppRoutes.shortDetail:
        final String? shortId = _safeIdentifier(
          uri.queryParameters['short_id'] ??
              uri.queryParameters['shortId'] ??
              uri.queryParameters['short'],
        );
        return shortId == null
            ? null
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.shortDetails,
                canonicalId: shortId,
              );
      case AppRoutes.liveRoom:
        final String? liveId = _safeIdentifier(
          uri.queryParameters['live_id'] ?? uri.queryParameters['liveId'],
        );
        return liveId == null
            ? null
            : ProtectedNavigationDestination(
                kind: ProtectedNavigationKind.live,
                canonicalId: liveId,
              );
    }

    final List<String> segments = uri.pathSegments;
    if (segments.length == 3 &&
        segments[0] == 'ads' &&
        segments[1] == 'detail') {
      final String? adId = _safeIdentifier(segments[2]);
      return adId == null
          ? null
          : ProtectedNavigationDestination(
              kind: ProtectedNavigationKind.adDetails,
              canonicalId: adId,
            );
    }

    if (segments.length == 3 &&
        segments[0] == 'chats' &&
        segments[1] == 'view') {
      final String? conversationId = _safeIdentifier(segments[2]);
      return conversationId == null
          ? null
          : ProtectedNavigationDestination(
              kind: ProtectedNavigationKind.messages,
              canonicalId: conversationId,
            );
    }

    return null;
  }
}

String? _readShortIdFromRoute(String? route) {
  final String? cleanRoute = _clean(route);
  if (cleanRoute == null ||
      !cleanRoute.startsWith('/') ||
      cleanRoute.startsWith('//')) {
    return null;
  }

  final Uri? uri = Uri.tryParse(cleanRoute);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      uri.fragment.isNotEmpty ||
      uri.path != AppRoutes.shortDetail ||
      uri.pathSegments.any((String segment) => segment == '..')) {
    return null;
  }

  return uri.queryParameters['short_id'] ??
      uri.queryParameters['shortId'] ??
      uri.queryParameters['short'];
}

String? _safeIdentifier(String? value) {
  final String? cleanValue = _clean(value);
  if (cleanValue == null || cleanValue.length > 200) return null;

  final RegExp allowed = RegExp(r'^[A-Za-z0-9._@+:-]+$');
  return allowed.hasMatch(cleanValue) ? cleanValue : null;
}

String? _safeDisplayText(String? value) {
  final String? cleanValue = _clean(value);
  if (cleanValue == null || cleanValue.length > 160) return null;
  if (cleanValue.contains(RegExp(r'[\u0000-\u001F\u007F]'))) return null;
  return cleanValue;
}

String? _safeMediaUrl(String? value) {
  final String? cleanValue = _clean(value);
  if (cleanValue == null || cleanValue.length > 2048) return null;

  final Uri? uri = Uri.tryParse(cleanValue);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  return cleanValue;
}

String? _clean(String? value) {
  final String? text = value?.trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}
