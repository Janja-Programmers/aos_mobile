import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/otp_resend_row.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/otp_section.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/app_success_sheet.dart';

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

  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length != 6) {
      ShowSnack(context, 'Enter the 6-digit code').error();
      return;
    }

    setState(() => _loading = true);
    try {
      final ctrl = ref.read(authControllerProvider.notifier);

      final result = (widget.purpose == OtpPurpose.passwordReset)
          ? await ctrl.forgotPasswordVerifyOtp(email: widget.email, otp: _otp)
          : await ctrl.verifyOtp(email: widget.email, otp: _otp);

      if (!mounted) return;

      await result.fold((f) async => ShowSnack(context, f.message).error(), (
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
        ShowSnack(context, right).success();

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
      ShowSnack(context, 'Unexpected error: $e').error();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      final ctrl = ref.read(authControllerProvider.notifier);

      final result = (widget.purpose == OtpPurpose.passwordReset)
          ? await ctrl.forgotPasswordRequest(email: widget.email)
          : await ctrl.resendOtp(email: widget.email);

      if (!mounted) return;

      result.fold(
        (f) => ShowSnack(context, f.message).error(),
        (msg) => ShowSnack(context, msg).success(),
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error: $e').error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = 'Email Verification';
    final header = 'Enter Verification Code';
    final subtitle = 'We have sent the verification code to';

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(screenTitle, style: context.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
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
            OtpResendRow(onResend: _resend),
          ],
        ),
      ),
    );
  }
}
