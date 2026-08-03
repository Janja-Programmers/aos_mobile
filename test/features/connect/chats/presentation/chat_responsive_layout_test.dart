import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_composer_area.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_messages_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'chat remains overflow-safe on small RTL screen with keyboard and 200% text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final scrollController = ScrollController();
      final inputController = TextEditingController(
        text: 'رسالة طويلة لاختبار التفاف النص مع لوحة المفاتيح المفتوحة',
      );
      addTearDown(scrollController.dispose);
      addTearDown(inputController.dispose);

      final original = ChatMessage(
        id: 'MSG-LONG',
        senderCanonicalId: 'ACC-CURRENT',
        messageType: 'text',
        hasAttachments: false,
        createdAt: DateTime.utc(2026, 1, 12, 9),
        attachments: const [],
        content:
            'This is a very long outgoing message that must wrap safely '
            'inside the bubble without changing ownership or overflowing.',
      );
      final translated = original.copyWith(
        translatedContent:
            'هذه ترجمة طويلة يجب أن تبقى منفصلة عن النص الأصلي وأن تلتف بأمان.',
        translationLanguage: 'Arabic',
      );
      const preferences = ChatLocalPreferencesState(
        conversationId: 'CONV-1',
        accountScope: 'ACC-CURRENT',
        loading: false,
        saving: false,
        wallpaperId: chatWallpaperDefaultId,
        enterToSend: false,
      );

      Future<bool> send({
        String? text,
        List<ChatInputAttachment> attachments = const [],
      }) async {
        return true;
      }

      await tester.pumpTestApp(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
            viewInsets: EdgeInsets.only(bottom: 240),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 320,
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: ChatMessagesView(
                      messagesState: ChatMessagesState(
                        messages: <ChatMessage>[translated],
                        isInitialLoading: false,
                        isLoadingMore: false,
                        hasMoreMessages: false,
                      ),
                      scrollController: scrollController,
                      currentUserId: 'ACC-CURRENT',
                      conversationId: 'CONV-1',
                      otherUserId: 'ACC-OTHER',
                      otherDisplayName: 'A very long translated contact name',
                      otherAvatarUrl: null,
                      preferences: preferences,
                      onReply: (_) {},
                      onLongPress: (_, _) {},
                      onRetry: (_) {},
                      onRetryInitial: () {},
                      onRetryOlder: () {},
                    ),
                  ),
                  ChatComposerArea(
                    isTyping: false,
                    showAdPreview: false,
                    adId: null,
                    adTitle: null,
                    adPrice: null,
                    adImage: null,
                    replyingTo: null,
                    inputController: inputController,
                    preferences: preferences,
                    onCloseAdPreview: () {},
                    onCloseReplyPreview: () {},
                    onTyping: (_) {},
                    onAudioCall: () {},
                    onVideoCall: () {},
                    onSend: send,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('very long outgoing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
