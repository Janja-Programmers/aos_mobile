import 'package:audioplayers/audioplayers.dart';

class VoiceSoundFeedbackService {
  VoiceSoundFeedbackService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player = AudioPlayer();

  static const String _startSound = 'audio/call_ringback.mp3';
  static const String _cancelSound = 'audio/call_ringback.mp3';

  Future<void> playStartCue() async {
    await _play(_startSound);
  }

  Future<void> playCancelCue() async {
    await _play(_cancelSound);
  }

  Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Sound feedback should never break recording.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
