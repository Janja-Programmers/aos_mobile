import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_ad_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input_bar.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_quick_replies.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/reply_composer_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/typing_indicator.dart';
import 'package:flutter/material.dart';

class ChatComposerArea extends StatelessWidget {
  final bool isTyping;
  final bool showAdPreview;
  final String? adId;
  final String? adTitle;
  final String? adPrice;
  final String? adImage;
  final ChatMessage? replyingTo;
  final TextEditingController inputController;
  final ChatLocalPreferencesState preferences;
  final ValueChanged<String> onQuickReplyTap;
  final VoidCallback onCloseAdPreview;
  final VoidCallback onCloseReplyPreview;
  final ValueChanged<bool> onTyping;
  final Future<void> Function({
    String? text,
    List<ChatInputAttachment> attachments,
  })
  onSend;

  const ChatComposerArea({
    super.key,
    required this.isTyping,
    required this.showAdPreview,
    required this.adId,
    required this.adTitle,
    required this.adPrice,
    required this.adImage,
    required this.replyingTo,
    required this.inputController,
    required this.preferences,
    required this.onQuickReplyTap,
    required this.onCloseAdPreview,
    required this.onCloseReplyPreview,
    required this.onTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isTyping) const TypingIndicator(isTyping: true),
        ChatQuickReplies(
          replies: const [
            'Is this still available?',
            'What’s your best price?',
            'Can you share your location?',
            'Can I call you about this item?',
          ],
          onTap: onQuickReplyTap,
        ),
        if (showAdPreview)
          ChatAdPreview(
            title: adTitle ?? '',
            price: adPrice ?? '',
            imageUrl: adImage,
            onClose: onCloseAdPreview,
          ),
        if (replyingTo != null)
          ReplyComposerPreview(
            message: replyingTo!,
            onClose: onCloseReplyPreview,
          ),
        ChatInputBar(
          controller: inputController,
          onSend: onSend,
          onTyping: onTyping,
          preferences: preferences,
          adId: showAdPreview ? adId : null,
        ),
      ],
    );
  }
}
