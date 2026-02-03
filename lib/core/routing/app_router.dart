import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/ui/login_screen.dart';
import 'package:africaonlinestores/features/auth/ui/register_screen.dart';
import 'package:africaonlinestores/features/auth/ui/verify_otp_screen.dart';
import 'package:africaonlinestores/features/auth/ui/forgot_password_screen.dart';
import 'package:africaonlinestores/features/auth/ui/reset_password_screen.dart';
import 'package:africaonlinestores/features/home/ui/home_screen.dart';
import 'package:africaonlinestores/features/catalog/ui/categories_screen.dart';
import 'package:africaonlinestores/features/account/ui/notification_screen.dart';
import 'package:africaonlinestores/features/account/ui/account_screen.dart';
import 'package:africaonlinestores/features/account/ui/privacy_policy_screen.dart';
import 'package:africaonlinestores/features/account/ui/terms_conditions_screen.dart';
import 'package:africaonlinestores/features/account/ui/update_profile_screen.dart';
import 'package:africaonlinestores/features/account/ui/password_security_screen.dart';
import 'package:africaonlinestores/features/account/ui/preference_screen.dart';

import 'package:africaonlinestores/features/ads/ui/ad_list.dart';
import 'package:africaonlinestores/features/ads/ui/create_ad_flow_screen.dart';
import 'package:africaonlinestores/features/ads/ui/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // auth state
  final auth = ref.watch(authControllerProvider);

  // listen to auth changes (StateNotifier stream)
  final authStream = ref.watch(authControllerProvider.notifier).stream;

  return GoRouter(
    initialLocation: AppRoutes.home,

    // ✅ Correct: GoRouter refreshes whenever auth notifier emits
    refreshListenable: GoRouterRefreshStream(authStream),

    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),

      // Ads / Listings
      GoRoute(
        path: AppRoutes.adList,
        builder: (context, state) => const AdListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAd,
        builder: (context, state) => const CreateAdFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectCategory,
        builder: (context, state) {
          final parent = state.extra is CategoryNode
              ? state.extra as CategoryNode
              : null;
          return SelectCategoryScreen(parent: parent);
        },
      ),
      GoRoute(
        path: AppRoutes.selectLocation,
        builder: (context, state) => const SelectLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const PushNotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final prefillEmail = state.uri.queryParameters['email'];
          return LoginScreen(prefillEmail: prefillEmail);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          String email = '';
          OtpPurpose purpose = OtpPurpose.emailVerification;

          if (state.extra is String) {
            email = state.extra as String;
          } else if (state.extra is Map) {
            final m = Map<String, dynamic>.from(state.extra as Map);
            email = (m['email'] ?? '').toString();
            final p = m['purpose'];
            if (p is OtpPurpose) purpose = p;
          }

          return VerifyOTPScreen(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
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
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          if (state.extra is Map) {
            final m = Map<String, dynamic>.from(state.extra as Map);
            final email = (m['email'] ?? '').toString();
            final token = (m['reset_token'] ?? '').toString();
            return ResetPasswordScreen(email: email, resetToken: token);
          }
          return const ResetPasswordScreen(email: '', resetToken: '');
        },
      ),
    ],

    redirect: (context, state) {
      // Home is always landing. We only block auth screens if already logged in.
      final goingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.verifyOtp ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword;

      final goingToUpdateProfile =
          state.matchedLocation == AppRoutes.updateProfile;
      final goingToPasswordSecurity =
          state.matchedLocation == AppRoutes.passwordSecurity;
      final goingToTerms = state.matchedLocation == AppRoutes.terms;
      final goingToPrivacy = state.matchedLocation == AppRoutes.privacy;

      if (!auth.isLoggedIn &&
          (goingToUpdateProfile || goingToPasswordSecurity)) {
        return AppRoutes.login;
      }

      if (!auth.isLoggedIn && (goingToTerms || goingToPrivacy)) {
        return null;
      }

      if (auth.isLoggedIn && goingToAuth) return AppRoutes.home;

      return null;
    },
  );
});

/// Refreshes GoRouter when the provided stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  Future<void> dispose() async {
    await _sub.cancel();
    super.dispose();
  }
}
