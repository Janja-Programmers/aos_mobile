import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conversation opening guard prevents repeated taps until completion', () {
    final controller = ChatConversationOpenController();

    expect(controller.tryBegin(), isTrue);
    expect(controller.tryBegin(), isFalse);

    controller.finish();

    expect(controller.tryBegin(), isTrue);
    controller.finish();
    controller.dispose();
  });
}
