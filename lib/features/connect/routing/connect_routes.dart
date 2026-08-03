import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/global_chat_settings_screen.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/screens/starred_messages_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/connect_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/screens/new_conversation_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/screens/story_template_confirm_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/screens/story_template_create_screen.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/screens/story_template_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectScreenRoutes {
  const ConnectScreenRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nConnectStarredMessages,
        path: AppRoutes.connectStarredMessages,
        builder: (context, state) => const StarredMessagesScreen(),
      ),
      GoRoute(
        name: AppRoutes.nConnectChatSettings,
        path: AppRoutes.connectChatSettings,
        builder: (context, state) => const GlobalChatSettingsScreen(),
      ),
      GoRoute(
        name: AppRoutes.nConnectNewConversation,
        path: AppRoutes.connectNewConversation,
        builder: (context, state) {
          return const NewConversationScreen();
        },
      ),
      GoRoute(
        name: AppRoutes.nConnectStoryCreate,
        path: AppRoutes.connectStoryCreate,
        builder: (context, state) {
          return const StoryTemplateCreateScreen();
        },
      ),
      GoRoute(
        name: AppRoutes.nConnectStoryConfirm,
        path: AppRoutes.connectStoryConfirm,
        builder: (context, state) {
          return const StoryTemplateConfirmScreen();
        },
      ),
      GoRoute(
        name: AppRoutes.nConnectStoryViewer,
        path: AppRoutes.connectStoryViewer,
        builder: (context, state) {
          final storyId = state.pathParameters['storyId'] ?? '';
          return StoryTemplateViewerScreen(storyId: storyId);
        },
      ),
      GoRoute(
        name: AppRoutes.nConnect,
        path: AppRoutes.connect,
        builder: (context, state) {
          return const ConnectScreen();
        },
      ),
    ];
  }
}

class ConnectScreenNavigation {
  const ConnectScreenNavigation._();

  static void toConnect(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect);
  }

  static void toNewConversation(BuildContext context) {
    context.pushNamed(AppRoutes.nConnectNewConversation);
  }

  static void toStarredMessages(BuildContext context) {
    context.pushNamed(AppRoutes.nConnectStarredMessages);
  }

  static void toChatSettings(BuildContext context) {
    context.pushNamed(AppRoutes.nConnectChatSettings);
  }

  static void toCreateStory(BuildContext context) {
    context.pushNamed(AppRoutes.nConnectStoryCreate);
  }

  static void toStoryViewer(BuildContext context, String storyId) {
    context.pushNamed(
      AppRoutes.nConnectStoryViewer,
      pathParameters: {'storyId': storyId},
    );
  }

  static void toCallsTab(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});
  }

  static void toMessagesTab(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect, queryParameters: {'tab': 'messages'});
  }
}
