import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveMediaService {
  final LiveKitService liveKit;

  LiveMediaService(this.liveKit);

  Future<void> joinLive({
    required String wsUrl,
    required String token,
    required AOSLiveRole role,
    bool micEnabled = true,
    bool cameraEnabled = true,
    bool frontCamera = true,
  }) async {
    final shouldPublish =
        role == AOSLiveRole.host || role == AOSLiveRole.cohost;

    if (shouldPublish) {
      final allowed = await _requestBroadcastPermissions();

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

    if (shouldPublish) {
      await liveKit.enableMicrophone(micEnabled);
      await liveKit.enableCamera(cameraEnabled, frontCamera: frontCamera);
      return;
    }

    await liveKit.enableMicrophone(false);
    await liveKit.enableCamera(false);
  }

  Future<void> leaveLive() async {
    await liveKit.disconnect();
  }

  Future<bool> _requestBroadcastPermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();

    final micAllowed = statuses[Permission.microphone]?.isGranted ?? false;
    final cameraAllowed = statuses[Permission.camera]?.isGranted ?? false;

    return micAllowed && cameraAllowed;
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    await liveKit.enableMicrophone(enabled);
  }

  Future<void> setCameraEnabled({
    required bool enabled,
    required bool frontCamera,
  }) async {
    await liveKit.enableCamera(enabled, frontCamera: frontCamera);
  }

  Future<bool> flipCamera() async {
    return liveKit.switchCamera();
  }

  List<LiveKitViewerParticipant> getViewerParticipants() {
    return liveKit.getViewerParticipants();
  }
}
