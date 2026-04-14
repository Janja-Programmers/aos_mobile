import 'package:permission_handler/permission_handler.dart';

import 'package:africaonlinestores/core/media/livekit_service.dart';

class CallMediaService {
  final LiveKitService liveKit;

  CallMediaService(this.liveKit);

  Future<void> joinCall({
    required String wsUrl,
    required String token,
    required bool isVideo,
  }) async {
    await _requestPermissions(isVideo);

    await liveKit.connect(wsUrl: wsUrl, token: token);

    await liveKit.enableMicrophone(true);
    await liveKit.enableCamera(isVideo);
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

  Future<void> _requestPermissions(bool isVideo) async {
    final permissions = [Permission.microphone, if (isVideo) Permission.camera];

    await permissions.request();
  }
}
