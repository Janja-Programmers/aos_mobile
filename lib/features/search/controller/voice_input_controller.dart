import 'dart:async';
import 'dart:io';

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
    Object? error = _keepError,
  }) {
    return VoiceInputState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      error: identical(error, _keepError) ? this.error : error as String?,
    );
  }
}

const Object _keepError = Object();

final voiceInputControllerProvider =
    StateNotifierProvider<VoiceInputController, VoiceInputState>((ref) {
      return VoiceInputController();
    });

class VoiceInputController extends StateNotifier<VoiceInputState> {
  VoiceInputController() : super(const VoiceInputState());

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _initialized = false;
  Timer? _autoStopTimer;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      final micStatus = await Permission.microphone.request();

      if (!micStatus.isGranted) {
        state = state.copyWith(
          isAvailable: false,
          isListening: false,
          error: 'Microphone permission denied',
        );
        return;
      }

      if (Platform.isIOS) {
        final speechStatus = await Permission.speech.request();

        if (!speechStatus.isGranted) {
          state = state.copyWith(
            isAvailable: false,
            isListening: false,
            error: 'Speech recognition permission denied',
          );
          return;
        }
      }

      final available = await _speech.initialize(
        onError: (error) {
          _clearAutoStopTimer();

          state = state.copyWith(isListening: false, error: error.errorMsg);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _clearAutoStopTimer();

            state = state.copyWith(isListening: false);
          }
        },
      );

      _initialized = available;

      state = state.copyWith(
        isAvailable: available,
        isListening: false,
        error: available ? null : 'Speech recognition unavailable',
      );
    } catch (_) {
      _initialized = false;

      state = state.copyWith(
        isAvailable: false,
        isListening: false,
        error: 'Speech recognition unavailable',
      );
    }
  }

  void reset() {
    state = state.copyWith(lastWords: '', error: null);
  }

  Future<void> toggleListening({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    if (state.isListening) {
      await stopListening();
      return;
    }

    await startListening(onWords: onWords);
  }

  Future<void> startListening({
    required void Function(String words, {required bool isFinal}) onWords,
  }) async {
    await _ensureInitialized();

    if (!state.isAvailable || state.isListening) return;

    _clearAutoStopTimer();

    state = state.copyWith(isListening: true, error: null, lastWords: '');

    try {
      await _speech.listen(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        onResult: (result) {
          final words = result.recognizedWords.trim();

          state = state.copyWith(lastWords: words);

          if (words.isNotEmpty) {
            onWords(words, isFinal: result.finalResult);
          }
        },
      );

      /// Safety timeout to avoid endless listening.
      _autoStopTimer = Timer(const Duration(seconds: 20), () {
        unawaited(stopListening());
      });
    } catch (_) {
      _clearAutoStopTimer();

      state = state.copyWith(
        isListening: false,
        error: 'Could not start voice input',
      );
    }
  }

  Future<void> stopListening() async {
    _clearAutoStopTimer();

    try {
      await _speech.stop();
    } catch (_) {
      // Ignore speech engine stop errors.
    }

    state = state.copyWith(isListening: false);
  }

  Future<void> cancel() async {
    _clearAutoStopTimer();

    try {
      await _speech.cancel();
    } catch (_) {
      // Ignore speech engine cancel errors.
    }

    state = state.copyWith(isListening: false);
  }

  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  void _clearAutoStopTimer() {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
  }

  @override
  void dispose() {
    _clearAutoStopTimer();
    unawaited(_speech.cancel());
    super.dispose();
  }
}
