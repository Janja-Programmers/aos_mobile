import 'dart:io';

import 'package:africaonlinestores/features/search/controller/voice_input_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('speech timeout is classified separately from user-visible errors', () {
    expect(isSpeechTimeoutError('error_speech_timeout'), isTrue);
    expect(isSpeechTimeoutError(' ERROR_SPEECH_TIMEOUT '), isTrue);
    expect(isSpeechTimeoutError('error_network'), isFalse);
    expect(isSpeechTimeoutError(null), isFalse);
  });

  test('voice provider mutations start after the first frame', () {
    final source = File(
      'lib/features/search/voice/voice_search_sheet.dart',
    ).readAsStringSync();

    final postFrame = source.indexOf(
      'WidgetsBinding.instance.addPostFrameCallback',
    );
    final reset = source.indexOf('controller.reset()');
    final start = source.indexOf('controller.startListening(');

    expect(postFrame, greaterThanOrEqualTo(0));
    expect(reset, greaterThan(postFrame));
    expect(start, greaterThan(reset));
    expect(source, contains('ref.listen<VoiceInputState>'));
  });
}
