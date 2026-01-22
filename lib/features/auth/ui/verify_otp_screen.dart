import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';

import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/shared/widgets/app_success_sheet.dart';

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
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    for (final n in _nodes) {
      n.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      FocusScope.of(context).unfocus();
      return;
    }

    if (value.isNotEmpty && index < 5) _nodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _nodes[index - 1].requestFocus();
  }

  Future<void> _verify() async {
    if (_otp.length != 6) {
      _snack('Enter the 6-digit code');
      return;
    }

    setState(() => _loading = true);
    try {
      final ctrl = ref.read(authControllerProvider.notifier);

      // Use the same UI for different OTP purposes, but call the correct backend.
      final result = (widget.purpose == OtpPurpose.passwordReset)
          ? await ctrl.forgotPasswordVerifyOtp(email: widget.email, otp: _otp)
          : await ctrl.verifyOtp(email: widget.email, otp: _otp);

      if (!mounted) return;

      await result.fold(
        (f) async {
          _snack(f.message);
        },
        (right) async {
          if (!mounted) return;

          if (widget.purpose == OtpPurpose.passwordReset) {
            final resetToken = right;
            context.go(
              AppRoutes.resetPassword,
              extra: {'email': widget.email, 'reset_token': resetToken},
            );
            return;
          }

          final msg = right;
          _snack(msg);
          await showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            backgroundColor: Colors.transparent,
            builder: (_) => AppSuccessSheet(
              title: 'Email Verified\nSuccessfully',
              message: 'Your email has been verified successfully',
              buttonText: 'Go To Login',
              onPressed: () {
                context.pop();
                context.go(
                  '${AppRoutes.login}?email=${Uri.encodeComponent(widget.email)}',
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _snack('Unexpected error: $e');
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
      result.fold((f) => _snack(f.message), (msg) => _snack(msg));
    } catch (e) {
      if (!mounted) return;
      _snack('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Widget _otpInputs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const int count = 6;
        const double gap = 10;

        final available = constraints.maxWidth - (gap * (count - 1));
        final w = (available / count).clamp(44.0, 56.0);
        const h = 56.0;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.spaceBetween,
          children: List.generate(count, (i) {
            return SizedBox(
              width: w,
              height: h,
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            );
          }),
        );
      },
    );
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            const SizedBox(height: 6),
            Center(
              child: Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFEFF1),
                ),
                child: Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text(header, style: AppTheme.h2(context))),
            const SizedBox(height: 10),
            Center(
              child: Text(
                subtitle,
                style: AppTheme.bodyMuted(context),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                widget.email,
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 22),
            _otpInputs(),
            const SizedBox(height: 22),
            AppTheme.primaryButton(
              text: 'Submit',
              onPressed: _loading ? null : _verify,
              loading: _loading,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppTheme.bodyMuted(context),
                ),
                GestureDetector(
                  onTap: _resending ? null : _resend,
                  child: Text(
                    _resending ? 'Sending...' : 'Resend',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

