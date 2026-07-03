import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class CallMediaService {
  final LiveKitService liveKit;

  CallMediaService(this.liveKit);

  Future<Room> joinCall({
    required String wsUrl,
    required String token,
    required bool isVideo,
  }) async {
    await _requestPermissions(isVideo);

    final room = await liveKit.connect(wsUrl: wsUrl, token: token);

    await liveKit.enableMicrophone(true);
    await liveKit.enableCamera(isVideo);

    return room;
  }

  Future<void> leaveCall() async {
    await liveKit.disconnect();
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
    final permissions = [Permission.microphone, if (isVideo) Permission.camera];

    final statuses = await permissions.request();
    final denied = statuses.entries.where((entry) => !entry.value.isGranted);

    if (denied.isNotEmpty) {
      throw StateError(
        isVideo
            ? 'Microphone and camera permissions are required for video calls.'
            : 'Microphone permission is required for calls.',
      );
    }
  }
}
