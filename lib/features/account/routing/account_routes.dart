import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/account/ui/account_screen.dart';
import 'package:africaonlinestores/features/account/ui/notification_screen.dart';
import 'package:africaonlinestores/features/account/ui/password_security_screen.dart';
import 'package:africaonlinestores/features/account/ui/preference_screen.dart';
import 'package:africaonlinestores/features/account/ui/privacy_policy_screen.dart';
import 'package:africaonlinestores/features/account/ui/terms_conditions_screen.dart';
import 'package:africaonlinestores/features/account/ui/update_profile_screen.dart';

class AccountRoutes {
  const AccountRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const PushNotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.updateProfile,
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.passwordSecurity,
        builder: (context, state) => const PasswordSecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.preference,
        builder: (context, state) => const PreferenceScreen(),
      ),
    ];
  }
}
