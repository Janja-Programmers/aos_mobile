import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';

import 'package:africaonlinestores/ui/components/app_success_sheet.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

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
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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

      await result.fold((f) async => showAppSnack(context, f.message), (
        _,
      ) async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          builder: (_) => AppSuccessSheet(
            title: 'Password Updated\nSuccessfully',
            message: 'Your password has been updated successfully',
            buttonText: 'Back To Login',
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
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
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
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
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
              Text('Enter your new password', style: context.bodyMuted),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pwCtrl,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      validator: (v) =>
                          Validators.minLen(v, 8, 'Min 8 characters'),
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pw2Ctrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      validator: (v) =>
                          (v != _pwCtrl.text) ? 'Passwords do not match' : null,
                      onFieldSubmitted: (_) => _save(),
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
