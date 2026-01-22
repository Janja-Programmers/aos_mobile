import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/features/auth/ui/verify_otp_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    final err = Validators.email(email);
    if (err != null) {
      _snack(err);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPasswordRequest(email: email);

      if (!mounted) return;
      result.fold((f) => _snack(f.message), (msg) {
        _snack(msg);
        context.go(
          AppRoutes.verifyOtp,
          extra: {'email': email, 'purpose': OtpPurpose.passwordReset},
        );
      });
    } catch (e) {
      if (!mounted) return;
      _snack('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            Text('Forgot Password', style: AppTheme.h2(context)),
            const SizedBox(height: 8),
            Text(
              'Enter your email address to reset your password',
              style: AppTheme.bodyMuted(context),
            ),
            const SizedBox(height: 22),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.inputDecoration(
                      label: 'Email Address',
                    ),
                    validator: Validators.email,
                    onFieldSubmitted: (_) => _sendOtp(),
                  ),
                  const SizedBox(height: 22),

                  AppTheme.primaryButton(
                    text: 'Send OTP',
                    onPressed: _loading ? null : _sendOtp,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
