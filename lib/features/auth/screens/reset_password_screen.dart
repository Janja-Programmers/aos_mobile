import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/shared/components/app_success_sheet.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  final String email;
  final String resetToken;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final pw1 = _pwCtrl.text;
    final pw2 = _pw2Ctrl.text;

    setState(() => _loading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPasswordReset(
            email: widget.email,
            resetToken: widget.resetToken,
            newPassword: pw1,
            confirmPassword: pw2,
          );

      if (!mounted) return;

      await result.fold(
        (e) async => ShowSnack(
          context,
          l10n.auth_unexpected_error(e.toString()),
        ).error(),
        (_) async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            backgroundColor: context.appColors.surface,
            builder: (_) => AppSuccessSheet(
              title: l10n.auth_password_updated_title,
              message: l10n.auth_password_updated_message,
              buttonText: l10n.auth_password_updated_button,
              onPressed: () {
                if (!context.mounted) return;

                // Close the sheet first (Navigator owns overlays).
                Navigator.of(context).pop();

                // Then route using go_router.
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
      ShowSnack(context, l10n.auth_unexpected_error(e.toString())).error();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text('Enter New Password', style: context.h2),
              const SizedBox(height: 8),
              Text('Enter your new password', style: context.p),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppPasswordFormField(
                      controller: _pwCtrl,
                      label: 'New Password',
                      validator: Validators.passwordRequired,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 16),
                    AppPasswordFormField(
                      controller: _pw2Ctrl,
                      label: 'Confirm Password',
                      validator: (v) =>
                          Validators.confirmPassword(v, _pwCtrl.text),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                text: 'Save',
                onPressed: _loading ? null : _save,
                loading: _loading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
