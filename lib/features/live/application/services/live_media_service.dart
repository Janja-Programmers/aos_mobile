import 'package:permission_handler/permission_handler.dart';

import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

class LiveMediaService {
  final LiveKitService liveKit;

  LiveMediaService(this.liveKit);

  Future<void> joinLive({
    required String wsUrl,
    required String token,
    required AOSLiveRole role,
    bool micEnabled = true,
  }) async {
    if (role == AOSLiveRole.host) {
      final allowed = await _requestHostPermissions();

      if (!allowed) {
        throw Exception('Camera and microphone permissions are required');
      }
    }

    final uri = Uri.tryParse(wsUrl);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw Exception('Invalid LiveKit URL: $wsUrl');
    }

    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw Exception(
        'LiveKit URL must start with ws:// or wss://. Got: $wsUrl',
      );
    }

    await liveKit.connect(wsUrl: wsUrl, token: token);

    if (role == AOSLiveRole.host) {
      await liveKit.enableMicrophone(micEnabled);
      await liveKit.enableCamera(true);
    } else {
      await liveKit.enableMicrophone(false);
      await liveKit.enableCamera(false);
    }
  }

  Future<void> leaveLive() async {
    await liveKit.disconnect();
  }

  Future<bool> _requestHostPermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();

    final micAllowed = statuses[Permission.microphone]?.isGranted == true;
    final cameraAllowed = statuses[Permission.camera]?.isGranted == true;

    return micAllowed && cameraAllowed;
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    await liveKit.enableMicrophone(enabled);
  }

  Future<void> flipCamera() async {
    try {
      await liveKit.switchCamera();
    } catch (_) {
      return;
    }
  }
}
