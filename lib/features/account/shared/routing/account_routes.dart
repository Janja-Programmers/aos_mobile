import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/account/presentation/account_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/delete_account_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/notification_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/password_security_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/privacy_policy_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/restore_account_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/terms_conditions_screen.dart';
import 'package:africaonlinestores/features/account/presentation/screens/user_preference_screen.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/user_verification_screen.dart';
import 'package:go_router/go_router.dart';

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
      GoRoute(
        name: AppRoutes.nUserVerification,
        path: AppRoutes.userVerification,
        builder: (context, state) => const UserVerificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.nDeleteAccount,
        path: AppRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        name: AppRoutes.nRestoreAccount,
        path: AppRoutes.restoreAccount,
        builder: (context, state) => const RestoreAccountScreen(),
      ),
    ];
  }
}
