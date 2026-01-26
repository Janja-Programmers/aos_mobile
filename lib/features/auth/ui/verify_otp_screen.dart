import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/otp_resend_row.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/otp_section.dart';

import 'package:africaonlinestores/ui/components/app_success_sheet.dart';

enum OtpPurpose { emailVerification, passwordReset }

class VerifyOTPScreen extends ConsumerStatefulWidget {
  const VerifyOTPScreen({
    super.key,
    required this.email,
    this.purpose = OtpPurpose.emailVerification,
  });

  final String email;
  final OtpPurpose purpose;

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  bool _loading = false;
  bool _resending = false;

  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length != 6) {
      showAppSnack(context, 'Enter the 6-digit code');
      return;
    }

    setState(() => _loading = true);
    try {
      final ctrl = ref.read(authControllerProvider.notifier);

      final result = (widget.purpose == OtpPurpose.passwordReset)
          ? await ctrl.forgotPasswordVerifyOtp(email: widget.email, otp: _otp)
          : await ctrl.verifyOtp(email: widget.email, otp: _otp);

      if (!mounted) return;

      await result.fold((f) async => showAppSnack(context, f.message), (
        right,
      ) async {
        if (!mounted) return;

        if (widget.purpose == OtpPurpose.passwordReset) {
          final resetToken = right;
          context.go(
            AppRoutes.resetPassword,
            extra: {'email': widget.email, 'reset_token': resetToken},
          );
          return;
        }

        // email verification success
        showAppSnack(context, right);

        await showModalBottomSheet(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          builder: (_) => AppSuccessSheet(
            title: 'Email Verified\nSuccessfully',
            message: 'Your email has been verified successfully',
            buttonText: 'Proceed To Login',
            onPressed: () {
              if (!context.mounted) return;

              // Close the sheet (Navigator owns overlays).
              Navigator.of(context).pop();

              // Then route using go_router.
              context.go(
                '${AppRoutes.login}?email=${Uri.encodeComponent(widget.email)}',
              );
            },
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final ctrl = ref.read(authControllerProvider.notifier);

      final result = (widget.purpose == OtpPurpose.passwordReset)
          ? await ctrl.forgotPasswordRequest(email: widget.email)
          : await ctrl.resendOtp(email: widget.email);

      if (!mounted) return;

      result.fold(
        (f) => showAppSnack(context, f.message),
        (msg) => showAppSnack(context, msg),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = (widget.purpose == OtpPurpose.passwordReset)
        ? 'Enter Verification Code'
        : 'Verification';
    final header = (widget.purpose == OtpPurpose.passwordReset)
        ? 'Enter Verification Code'
        : 'Verify OTP';
    final subtitle = (widget.purpose == OtpPurpose.passwordReset)
        ? 'We have sent a verification code to your email address'
        : 'We have sent the verification code to';

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          screenTitle,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            OtpSection(
              header: header,
              subtitle: subtitle,
              email: widget.email,
              enabled: !_loading,
              onChanged: (v) => setState(() => _otp = v),
              onCompleted: (_) => _verify(),
              showCustomKeypad: true,
            ),
            const SizedBox(height: 18),
            OtpResendRow(
              resending: _resending,
              onResend: _resending ? null : _resend,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
