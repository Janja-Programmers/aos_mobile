import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_not_answered_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/connect_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/active_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/incoming_call_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/outgoing_call_screen.dart';

class CallRoutes {
  const CallRoutes._();

  static List<GoRoute> routes() => [
    // Chat list
    GoRoute(
      name: AppRoutes.nCalls,
      path: AppRoutes.calls,
      builder: (context, state) {
        return const CallScreen();
      },
    ),

    // Chat screen
    GoRoute(
      name: AppRoutes.nContact,
      path: AppRoutes.contact,
      builder: (context, state) {
        return const ContactScreen();
      },
    ),

    GoRoute(
      name: AppRoutes.nIncomingCall,
      path: AppRoutes.incomingCall,
      builder: (_, _) => const IncomingCallScreen(),
    ),

    GoRoute(
      name: AppRoutes.nOutgoingCall,
      path: AppRoutes.outgoingCall,
      builder: (_, _) => const OutgoingCallScreen(),
    ),

    GoRoute(
      name: AppRoutes.nActiveCall,
      path: AppRoutes.activeCall,
      builder: (_, _) => const ActiveCallScreen(),
    ),

    GoRoute(
      name: AppRoutes.nCallNotAnswered,
      path: AppRoutes.callNotAnswered,
      builder: (_, _) => const CallNotAnsweredScreen(),
    ),
  ];
}
