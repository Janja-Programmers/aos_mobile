import 'dart:io';

import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class CallMediaService {
  final LiveKitService liveKit;

  CallMediaService(this.liveKit);

  Future<void> prepareForCall({required bool isVideo}) async {
    appLogger.i('📞 Preparing call media permissions (video=$isVideo)');
    await _requestBluetoothPermissionsBestEffort();
    await _requestRequiredMediaPermissions(isVideo);
    await liveKit.prepareExternalCallAudioLifecycle();
  }

  Future<Room> joinCall({
    required String wsUrl,
    required String token,
    required bool isVideo,
    bool permissionsAlreadyPrepared = false,
  }) async {
    if (!permissionsAlreadyPrepared) {
      await prepareForCall(isVideo: isVideo);
    } else {
      // Idempotent: ensures the CallKit/LiveKit audio contract is configured
      // even if permission preparation happened earlier in the accept flow.
      await liveKit.prepareExternalCallAudioLifecycle();
    }

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
    Object? disconnectError;
    StackTrace? disconnectStackTrace;

    try {
      await liveKit.disconnect();
      appLogger.i('📞 LiveKit leave completed');
    } catch (error, stackTrace) {
      disconnectError = error;
      disconnectStackTrace = stackTrace;
      appLogger.w(
        '📞 LiveKit leave failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      try {
        await liveKit.restoreAutomaticAudioLifecycle();
      } catch (error, stackTrace) {
        appLogger.w(
          '📞 LiveKit audio lifecycle reset failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (disconnectError != null) {
      Error.throwWithStackTrace(disconnectError, disconnectStackTrace!);
    }
  }

  Future<void> handleExternalAudioSessionChanged(bool isActive) async {
    appLogger.i('📞 CallKit audio session active=$isActive');
    await liveKit.setExternalCallAudioSessionActive(isActive);
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

  Future<void> _requestBluetoothPermissionsBestEffort() async {
    if (!Platform.isAndroid) return;

    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothConnect,
    ];

    try {
      final statuses = await permissions.request();
      final denied = statuses.entries.where((entry) => !entry.value.isGranted);
      if (denied.isNotEmpty) {
        appLogger.w(
          '📞 Bluetooth permission not granted; call will continue with '
          'available handset/wired audio routing '
          '(state=${_describePermissions(statuses)})',
        );
      }
    } catch (error, stackTrace) {
      // Bluetooth is optional for the call itself. Never block microphone/call
      // establishment because a device/API level does not expose the permission.
      appLogger.w(
        '📞 Bluetooth permission preparation failed; continuing call setup',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _requestRequiredMediaPermissions(bool isVideo) async {
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
