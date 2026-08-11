import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveCohost {
  final String id;
  final String liveId;
  final String user;
  final String? sessionId;
  final String? livekitIdentity;
  final String requestType;
  final String status;
  final bool isActive;
  final String candidateDisplayName;
  final String? candidateAvatar;
  final DateTime? expiresAt;

  const LiveCohost({
    required this.id,
    required this.liveId,
    required this.user,
    this.sessionId,
    this.livekitIdentity,
    required this.requestType,
    required this.status,
    required this.isActive,
    required this.candidateDisplayName,
    this.candidateAvatar,
    this.expiresAt,
  });

  String get displayName {
    final value = candidateDisplayName.trim();
    if (value.isNotEmpty) return value;
    return user.trim().isEmpty ? 'Viewer' : user.trim();
  }

  String? get avatar =>
      candidateAvatar?.trim().isNotEmpty ?? false ? candidateAvatar : null;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled' || status == 'canceled';
  bool get isEnded => status == 'ended' || status == 'expired';
  bool get isActiveStatus => status == 'active' || isActive;
  bool get isHostInvite => requestType == 'host_invite';
  bool get isViewerRequest => requestType == 'viewer_request';

  factory LiveCohost.fromJson(Map<String, dynamic> json) {
    final rawCandidate =
        json['cohost'] ?? json['candidate'] ?? json['user_display'];
    final candidate = rawCandidate is Map<Object?, Object?>
        ? asJsonMap(rawCandidate)
        : null;
    final user =
        json['user']?.toString() ??
        candidate?['user']?.toString() ??
        candidate?['email']?.toString() ??
        '';
    final displayName =
        json['display_name']?.toString() ??
        candidate?['display_name']?.toString() ??
        candidate?['full_name']?.toString() ??
        user;
    final avatar =
        json['avatar']?.toString() ??
        candidate?['avatar']?.toString() ??
        candidate?['user_image']?.toString();

    return LiveCohost(
      id: json['cohost_id']?.toString() ?? json['id']?.toString() ?? '',
      liveId:
          json['live_id']?.toString() ?? json['live_stream']?.toString() ?? '',
      user: user,
      sessionId: json['session_id']?.toString(),
      livekitIdentity: json['livekit_identity']?.toString(),
      requestType: json['request_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString() == '1',
      candidateDisplayName: displayName,
      candidateAvatar: avatar,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }
}
