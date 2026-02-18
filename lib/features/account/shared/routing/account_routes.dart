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
        name: AppRoutes.nNotifications,
        path: AppRoutes.notifications,
        builder: (context, state) => const PushNotificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.nAccount,
        path: AppRoutes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        name: AppRoutes.nUpdateProfile,
        path: AppRoutes.updateProfile,
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.nPasswordSecurity,
        path: AppRoutes.passwordSecurity,
        builder: (context, state) => const PasswordSecurityScreen(),
      ),
      GoRoute(
        name: AppRoutes.nTerms,
        path: AppRoutes.terms,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        name: AppRoutes.nPrivacy,
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: AppRoutes.nPreference,
        path: AppRoutes.preference,
        builder: (context, state) => const PreferenceScreen(),
      ),
    ];
  }
}
