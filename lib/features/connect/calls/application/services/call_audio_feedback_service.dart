import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:audioplayers/audioplayers.dart';

class CallAudioFeedbackService {
  final AudioPlayer _ringbackPlayer = AudioPlayer();

  StreamSubscription<void>? _completionSub;

  bool _isRingbackPlaying = false;

  CallAudioFeedbackService() {
    _completionSub = _ringbackPlayer.onPlayerComplete.listen((_) async {
      if (!_isRingbackPlaying) return;

      try {
        await _ringbackPlayer.seek(Duration.zero);
        await _ringbackPlayer.resume();
      } catch (e, s) {
        appLogger.w(
          '⚠️ Failed to restart ringback loop',
          error: e,
          stackTrace: s,
        );
      }
    });
  }

  Future<void> playRingback() async {
    if (_isRingbackPlaying) return;

    try {
      _isRingbackPlaying = true;

      await _ringbackPlayer.stop();
      await _ringbackPlayer.setReleaseMode(ReleaseMode.loop);

      await _ringbackPlayer.play(
        AssetSource('audio/call_ringback.mp3'),
        volume: 1.0,
      );

      appLogger.i('🔔 Ringback started');
    } catch (e, s) {
      _isRingbackPlaying = false;

      appLogger.w('⚠️ Failed to start ringback', error: e, stackTrace: s);
    }
  }

  Future<void> stopRingback() async {
    if (!_isRingbackPlaying) return;

    try {
      _isRingbackPlaying = false;
      await _ringbackPlayer.stop();

      appLogger.i('🔕 Ringback stopped');
    } catch (e, s) {
      appLogger.w('⚠️ Failed to stop ringback', error: e, stackTrace: s);
    }
  }

  Future<void> dispose() async {
    _isRingbackPlaying = false;

    await _completionSub?.cancel();
    _completionSub = null;

    await _ringbackPlayer.dispose();
  }
}
