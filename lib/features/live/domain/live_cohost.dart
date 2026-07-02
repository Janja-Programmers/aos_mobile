import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveCohost {
  final String id;
  final String liveId;
  final String user;
  final String? sessionId;
  final String requestType;
  final String status;
  final bool isActive;
  final Map<String, dynamic>? candidate;
  final DateTime? expiresAt;

  const LiveCohost({
    required this.id,
    required this.liveId,
    required this.user,
    this.sessionId,
    required this.requestType,
    required this.status,
    required this.isActive,
    this.candidate,
    this.expiresAt,
  });

  String get displayName =>
      candidate?['display_name']?.toString() ??
      candidate?['full_name']?.toString() ??
      user;

  String? get avatar =>
      candidate?['avatar']?.toString() ?? candidate?['user_image']?.toString();

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isActiveStatus => status == 'active' || isActive;

  factory LiveCohost.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'] ?? json['user_display'];
    return LiveCohost(
      id: json['cohost_id']?.toString() ?? json['id']?.toString() ?? '',
      liveId:
          json['live_id']?.toString() ?? json['live_stream']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      sessionId: json['session_id']?.toString(),
      requestType: json['request_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString() == '1',
      candidate: candidate is Map ? asJsonMap(candidate) : null,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }
}
