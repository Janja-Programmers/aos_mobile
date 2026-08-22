import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('voice-note attachment aliases use the audio presentation path', () {
    for (final type in const <String>['audio', 'voice', 'voice_note']) {
      final attachment = ChatAttachment(
        url: '/media/$type.m4a',
        type: type,
        sortOrder: 0,
      );
      expect(attachment.isAudio, isTrue, reason: type);
      expect(attachment.isDocument, isFalse, reason: type);
    }
  });
}
