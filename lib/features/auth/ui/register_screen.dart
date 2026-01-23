import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';

import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/features/account/ui/legal_docs_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _accept = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openLegalSheet({required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_accept) {
      _snack('Please accept Terms & Conditions and Privacy Policy');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim().toLowerCase(),
            password: _password.text,
            fullName: _name.text.trim(),
          );

      if (!mounted) return;

      await result.fold((f) async => _snack(f.message), (msg) async {
        _snack(msg);
        // Go to OTP verification; pass email via extra
        await context.push(
          AppRoutes.verifyOtp,
          extra: _email.text.trim().toLowerCase(),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView(
            children: [
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 56,
                  width: 56,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text('Register', style: AppTheme.h1(context)),
              const SizedBox(height: 6),
              Text(
                'Enter your details below to create your account',
                style: AppTheme.bodyMuted(context),
              ),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: AppTheme.inputDecoration(label: 'Full Name'),
                      validator: (v) => Validators.minLen(
                        v?.trim(),
                        2,
                        'Enter your full name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppTheme.inputDecoration(
                        label: 'Email Address',
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
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
                      validator: (v) => (v != _password.text)
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _accept,
                    onChanged: (v) => setState(() => _accept = v ?? false),
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: AppColors.text),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openLegalSheet(
                                title: 'Terms & Conditions',
                                child: const TermsConditionsContent(),
                              ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openLegalSheet(
                                title: 'Privacy Policy',
                                child: const PrivacyPolicyContent(),
                              ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              AppTheme.primaryButton(
                text: 'Register',
                onPressed: _loading ? null : _register,
                loading: _loading,
              ),

              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.stroke)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or Continue with',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.stroke)),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  AppTheme.socialButton(
                    icon: SvgPicture.asset(
                      'assets/icons/google.svg',
                      width: 22,
                      height: 22,
                    ),
                    text: 'Google',
                    onTap: () => _snack('Google signup coming soon.'),
                  ),
                  const SizedBox(width: 12),
                  AppTheme.socialButton(
                    icon: SvgPicture.asset(
                      'assets/icons/apple.svg',
                      width: 22,
                      height: 22,
                    ),
                    text: 'Apple',
                    onTap: () => _snack('Apple signup coming soon.'),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTheme.bodyMuted(context),
                  ),
                  GestureDetector(
                    onTap: () => context.push(
                      '${AppRoutes.login}?email=${Uri.encodeComponent(_email.text.trim().toLowerCase())}',
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
