import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

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
    final l10n = context.l10n;

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
        context.pushNamed(
          AppRoutes.nVerifyOtp,
          extra: {'email': email, 'purpose': OtpPurpose.passwordReset},
        );
      });
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, l10n.auth_unexpected_error(e.toString())).error();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scheme.surface,
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
            Text(l10n.auth_forgot_password, style: context.h3),
            const SizedBox(height: 8),
            Text(l10n.auth_mail_reset_password, style: context.p),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    label: l10n.auth_email_address,
                    validator: Validators.email,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: l10n.auth_send_otp,
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
