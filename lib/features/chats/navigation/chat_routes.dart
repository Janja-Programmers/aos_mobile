import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/chats/presentation/screens/chat_screen.dart';
import 'package:africaonlinestores/features/chats/presentation/screens/chat_list_screen.dart';

class ChatRoutes {
  const ChatRoutes._();

  static List<GoRoute> routes() => [
    // Chat list
    GoRoute(
      name: AppRoutes.nChats,
      path: AppRoutes.chats,
      builder: (context, state) {
        return const ChatListScreen();
      },
    ),

    // Chat screen
    GoRoute(
      name: AppRoutes.nMessages,
      path: AppRoutes.messages,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return ChatScreen(
          conversationId: state.pathParameters['conversationId'] ?? '',
          otherUser: extra?['otherUser'] ?? '',
          displayName: extra?['displayName'] ?? '',
          initialMessage: extra?['initialMessage'],
        );
      },
    ),
  ];
}

class ChatNavigation {
  const ChatNavigation._();

  static void toChats(BuildContext context) {
    context.pushNamed(AppRoutes.nChats);
  }

  static void toMessage({
    required BuildContext context,
    required String conversationId,
    required String user,
    required String displayName,
    String? initialMessage,
  }) {
    context.pushNamed(
      AppRoutes.nMessages,
      pathParameters: {'conversationId': conversationId},
      extra: {
        'otherUser': user,
        'displayName': displayName,
        'initialMessage': initialMessage,
      },
    );
  }
}
