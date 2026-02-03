import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/ui/verify_otp_screen.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';
import 'package:africaonlinestores/ui/components/app_text_fields.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

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

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    final err = Validators.email(email);
    if (err != null) {
      ShowSnack(context, err).error();
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPasswordRequest(email: email);

      if (!mounted) return;

      result.fold((f) => ShowSnack(context, f.message).error(), (msg) {
        ShowSnack(context, msg).success();
        context.push(
          AppRoutes.verifyOtp,
          extra: {'email': email, 'purpose': OtpPurpose.passwordReset},
        );
      });
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error: $e').error();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            Text('Forgot Password', style: context.h3),
            const SizedBox(height: 8),
            Text(
              'Enter your email address to reset your password',
              style: context.p,
            ),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    label: 'Email Address',
                    validator: Validators.email,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
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
