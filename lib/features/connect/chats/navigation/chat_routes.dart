import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/chat_list_screen.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/chat_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/screens/new_conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatRoutes {
  const ChatRoutes._();

  static List<GoRoute> routes() => [
    // Preserve the legacy route while using the single new-conversation UI.
    GoRoute(
      name: AppRoutes.nNewMessage,
      path: AppRoutes.newMessage,
      builder: (context, state) => const NewConversationScreen(),
    ),

    // Conversation list.
    GoRoute(
      name: AppRoutes.nChatsList,
      path: AppRoutes.chatsList,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'];
        return ChatListScreen(searchQuery: searchQuery);
      },
    ),

    // Dynamic conversation route must remain last.
    GoRoute(
      name: AppRoutes.nMessages,
      path: AppRoutes.messages,
      pageBuilder: (context, state) {
        final extra = asJsonMap(state.extra);
        final conversationId = state.pathParameters['conversationId'] ?? '';

        return MaterialPage(
          key: ValueKey('chat_$conversationId'),
          child: ChatScreen(
            conversationId: conversationId,
            otherUser: asString(extra['otherUser']),
            displayName: asString(extra['displayName']),
            otherUserAvatar: asNullableString(extra['otherUserAvatar']),
            initialMessage: asNullableString(extra['initialMessage']),
            adId: asNullableString(extra['adId']),
            adTitle: asNullableString(extra['adTitle']),
            adPrice: asNullableString(extra['adPrice']),
            adImage: asNullableString(extra['adImage']),
            adImageFileId: asNullableString(extra['adImageFileId']),
          ),
        );
      },
    ),
  ];
}

class ChatNavigation {
  const ChatNavigation._();

  static void toChatsList(BuildContext context, {String? search}) {
    context.pushNamed(
      AppRoutes.nChatsList,
      queryParameters: (search != null && search.isNotEmpty)
          ? {'search': search}
          : {},
    );
  }

  static void toMessage({
    required BuildContext context,
    required String conversationId,
    required String user,
    required String displayName,
    final String? otherUserAvatar,
    String? initialMessage,
    final String? adId,
    final String? adTitle,
    final String? adPrice,
    final String? adImage,
    final String? adImageFileId,
  }) {
    context.pushNamed(
      AppRoutes.nMessages,
      pathParameters: {'conversationId': conversationId},
      extra: {
        'otherUser': user,
        'displayName': displayName,
        'otherUserAvatar': otherUserAvatar,
        'initialMessage': initialMessage,
        'adId': adId,
        'adTitle': adTitle,
        'adPrice': adPrice,
        'adImage': adImage,
        'adImageFileId': adImageFileId,
      },
    );
  }

  static void toNewMessage(BuildContext context) {
    context.pushNamed(AppRoutes.nNewMessage);
  }
}
