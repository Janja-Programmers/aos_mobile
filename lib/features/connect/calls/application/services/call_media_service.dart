import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class CallMediaService {
  final LiveKitService liveKit;

  CallMediaService(this.liveKit);

  Future<void> prepareForCall({required bool isVideo}) async {
    appLogger.i('📞 Preparing call media permissions (video=$isVideo)');
    await _requestPermissions(isVideo);
  }

  Future<Room> joinCall({
    required String wsUrl,
    required String token,
    required bool isVideo,
  }) async {
    await _requestPermissions(isVideo);

    final host = Uri.tryParse(wsUrl)?.host;
    appLogger.i(
      '📞 LiveKit join started '
      '(video=$isVideo, host=${host?.isNotEmpty ?? false ? host : 'unknown'}, '
      'tokenPresent=${token.trim().isNotEmpty})',
    );

    try {
      final room = await liveKit.connect(wsUrl: wsUrl, token: token);

      await liveKit.enableMicrophone(true);
      await liveKit.enableCamera(isVideo);

      appLogger.i('📞 LiveKit join completed (video=$isVideo)');
      return room;
    } catch (error, stackTrace) {
      appLogger.e(
        '📞 LiveKit join failed (video=$isVideo)',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> leaveCall() async {
    appLogger.i('📞 LiveKit leave requested');
    try {
      await liveKit.disconnect();
      appLogger.i('📞 LiveKit leave completed');
    } catch (error, stackTrace) {
      appLogger.w(
        '📞 LiveKit leave failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> toggleMute(bool enabled) async {
    await liveKit.enableMicrophone(enabled);
  }

  Future<void> toggleCamera(bool enabled) async {
    await liveKit.enableCamera(enabled);
  }

  Future<void> switchSpeaker(bool enabled) async {
    await liveKit.switchSpeaker(enabled);
  }

  Future<void> switchCamera() async {
    await liveKit.switchCamera();
  }

  Future<void> _requestPermissions(bool isVideo) async {
    final permissions = <Permission>[
      Permission.microphone,
      if (isVideo) Permission.camera,
    ];

    final before = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      before[permission] = await permission.status;
    }

    appLogger.i(
      '📞 Call media permission state before request: '
      '${_describePermissions(before)}',
    );

    final statuses = await permissions.request();
    appLogger.i(
      '📞 Call media permission state after request: '
      '${_describePermissions(statuses)}',
    );

    final denied = statuses.entries.where((entry) => !entry.value.isGranted);

    if (denied.isNotEmpty) {
      final permanentlyDenied = denied.any(
        (entry) => entry.value.isPermanentlyDenied,
      );
      appLogger.w(
        '📞 Required call media permission denied '
        '(video=$isVideo, permanentlyDenied=$permanentlyDenied, '
        'state=${_describePermissions(statuses)})',
      );

      throw StateError(
        isVideo
            ? 'Microphone and camera permissions are required for video calls.'
            : 'Microphone permission is required for calls.',
      );
    }
  }

  String _describePermissions(Map<Permission, PermissionStatus> statuses) {
    return statuses.entries
        .map((entry) => '${entry.key}: ${entry.value.name}')
        .join(', ');
  }
}
