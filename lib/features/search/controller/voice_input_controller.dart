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

class VoiceInputController extends StateNotifier<VoiceInputState> {
  VoiceInputController() : super(const VoiceInputState());

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _initialized = false;
  Timer? _autoStopTimer;

  /// Ensure speech engine ready
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      final status = await Permission.microphone.request();

      if (!status.isGranted) {
        state = state.copyWith(
          isAvailable: false,
          isListening: false,
          error: "Microphone permission denied",
        );
        _initialized = true;
        return;
      }

      final available = await _speech.initialize(
        onError: (e) {
          state = state.copyWith(isListening: false, error: e.errorMsg);
        },
        onStatus: (s) {
          if (s == "done" || s == "notListening") {
            state = state.copyWith(isListening: false);
          }
        },
      );

      _initialized = true;

      state = state.copyWith(isAvailable: available, error: null);
    } catch (_) {
      _initialized = true;

      state = state.copyWith(
        isAvailable: false,
        isListening: false,
        error: "Speech recognition unavailable",
      );
    }
  }

  /// Reset last words
  void reset() {
    state = state.copyWith(lastWords: '', error: null);
  }

  /// Toggle listening
  Future<void> toggleListening({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    if (state.isListening) {
      await stopListening();
      return;
    }

    await startListening(onWords: onWords);
  }

  /// Start speech listening
  Future<void> startListening({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    await _ensureInitialized();

    if (!state.isAvailable || state.isListening) return;

    _autoStopTimer?.cancel();

    state = state.copyWith(isListening: true, error: null, lastWords: '');

    await _speech.listen(
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      cancelOnError: true,
      onResult: (r) {
        final words = r.recognizedWords.trim();

        if (words.isEmpty) return;

        state = state.copyWith(lastWords: words);

        onWords(words, isFinal: r.finalResult);
      },
    );

    /// Auto stop if user stays silent
    _autoStopTimer = Timer(const Duration(seconds: 20), () {
      stopListening();
    });
  }

  /// Stop listening
  Future<void> stopListening() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    try {
      await _speech.stop();
    } catch (_) {}

    state = state.copyWith(isListening: false);
  }

  /// Cancel completely
  Future<void> cancel() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    try {
      await _speech.cancel();
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
