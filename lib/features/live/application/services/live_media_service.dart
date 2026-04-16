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
  }) async {
    if (role == AOSLiveRole.host) {
      await _requestHostPermissions();
    }

    await liveKit.connect(wsUrl: wsUrl, token: token);

    if (role == AOSLiveRole.host) {
      await liveKit.enableMicrophone(true);
      await liveKit.enableCamera(true);
    } else {
      await liveKit.enableMicrophone(false);
      await liveKit.enableCamera(false);
    }
  }

  Future<void> leaveLive() async {
    await liveKit.disconnect();
  }

  Future<void> _requestHostPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> flipCamera() async {
    try {
      await liveKit.switchCamera();
      // ignore: empty_catches
    } catch (e) {
      return;
    }
  }
}
