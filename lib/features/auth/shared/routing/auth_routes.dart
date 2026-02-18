import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/auth/screens/forgot_password_screen.dart';
import 'package:africaonlinestores/features/auth/screens/login_screen.dart';
import 'package:africaonlinestores/features/auth/screens/register_screen.dart';
import 'package:africaonlinestores/features/auth/screens/reset_password_screen.dart';
import 'package:africaonlinestores/features/auth/screens/verify_otp_screen.dart';

class AuthRoutes {
  const AuthRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nLogin,
        path: AppRoutes.login,
        builder: (context, state) {
          final prefillEmail = state.uri.queryParameters['email'];
          return LoginScreen(prefillEmail: prefillEmail);
        },
      ),
      GoRoute(
        name: AppRoutes.nRegister,
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRoutes.nVerifyOtp,
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
        name: AppRoutes.nForgotPassword,
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.nResetPassword,
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
    ];
  }
}
