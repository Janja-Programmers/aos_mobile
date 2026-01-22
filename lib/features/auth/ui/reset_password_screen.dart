import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/shared/widgets/app_success_sheet.dart';

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

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

      await result.fold((f) async => _snack(f.message), (msg) async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: false,
          backgroundColor: Colors.transparent,
          builder: (_) => AppSuccessSheet(
            title: 'Password Updated\nSuccessfully',
            message: 'Your password has been updated successfully',
            buttonText: 'Back To Login',
            onPressed: () {
              context.pop();
              context.go(
                '${AppRoutes.login}?email=${Uri.encodeComponent(widget.email)}',
              );
            },
          ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text('Enter New Password', style: AppTheme.h2(context)),
              const SizedBox(height: 8),
              Text(
                'Enter your new password',
                style: AppTheme.bodyMuted(context),
              ),
              const SizedBox(height: 22),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pwCtrl,
                      obscureText: _obscure1,
                      decoration: AppTheme.inputDecoration(
                        label: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          Validators.minLen(v, 8, 'Min 8 characters'),
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pw2Ctrl,
                      obscureText: _obscure2,
                      decoration: AppTheme.inputDecoration(
                        label: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v != _pwCtrl.text) ? 'Passwords do not match' : null,
                      onFieldSubmitted: (_) => _save(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              AppTheme.primaryButton(
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

