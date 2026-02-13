import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputState {
  const VoiceInputState({
    this.isAvailable = false,
    this.isListening = false,
    this.lastWords = '',
    this.error,
  });

  final bool isAvailable;
  final bool isListening;
  final String lastWords;
  final String? error;

  VoiceInputState copyWith({
    bool? isAvailable,
    bool? isListening,
    String? lastWords,
    String? error,
  }) {
    return VoiceInputState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      error: error,
    );
  }
}

final voiceInputControllerProvider =
    StateNotifierProvider<VoiceInputController, VoiceInputState>((ref) {
      return VoiceInputController();
    });

/// Small wrapper around speech_to_text.
///
/// Conventions:
/// - Keep speech logic out of UI.
/// - Expose minimal state + toggle/start/stop.
class VoiceInputController extends StateNotifier<VoiceInputState> {
  VoiceInputController() : super(const VoiceInputState());

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  Timer? _autoStopTimer;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      // Ask permission first for better UX.
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        state = state.copyWith(
          isAvailable: false,
          isListening: false,
          error: 'Microphone permission denied.',
        );
        _initialized = true; // avoid repeating prompts
        return;
      }

      final ok = await _speech.initialize(
        onError: (e) {
          state = state.copyWith(isListening: false, error: e.errorMsg);
        },
        onStatus: (s) {
          // speech_to_text emits "notListening" / "listening".
          if (s == 'notListening') {
            state = state.copyWith(isListening: false);
          }
        },
      );

      _initialized = true;
      state = state.copyWith(isAvailable: ok, error: null);
    } catch (_) {
      _initialized = true;
      state = state.copyWith(
        isAvailable: false,
        isListening: false,
        error: 'Speech recognition unavailable.',
      );
    }
  }

  Future<void> toggleListening({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    if (state.isListening) {
      await stop();
      return;
    }
    await start(onWords: onWords);
  }

  Future<void> start({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    await _ensureInitialized();
    if (!state.isAvailable) return;

    _autoStopTimer?.cancel();
    state = state.copyWith(isListening: true, error: null);

    await _speech.listen(
      onResult: (r) {
        final words = (r.recognizedWords).trim();
        if (words.isEmpty) return;
        state = state.copyWith(lastWords: words);
        onWords(words, isFinal: r.finalResult);
      },
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      cancelOnError: true,
    );

    // Safety: auto-stop after a short period if user forgets.
    _autoStopTimer = Timer(const Duration(seconds: 20), () {
      stop();
    });
  }

  Future<void> stop() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    try {
      await _speech.stop();
    } catch (_) {}
    state = state.copyWith(isListening: false);
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }
}
