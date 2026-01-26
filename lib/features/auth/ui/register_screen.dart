import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/account/ui/legal_docs_widgets.dart';
import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/platform_social_section.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

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

  bool _googleLoading = false;
  bool _registerLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _accept = true;

  bool get _busy => _registerLoading || _googleLoading;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _openLegalSheet({required String title, required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: colors.stroke,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors.text,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.of(sheetContext).pop(),
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
      showAppSnack(
        context,
        'Please accept Terms & Conditions and Privacy Policy',
      );
      return;
    }

    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _registerLoading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim().toLowerCase(),
            password: _password.text,
            fullName: _name.text.trim(),
          );

      if (!mounted) return;

      await result.fold((f) async => showAppSnack(context, f.message), (
        msg,
      ) async {
        showAppSnack(context, msg);
        await context.push(
          AppRoutes.verifyOtp,
          extra: _email.text.trim().toLowerCase(),
        );
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    if (_busy) return;

    setState(() => _googleLoading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle();

      if (!mounted) return;

      result.fold(
        (f) => showAppSnack(context, f.message),
        (_) => context.go(AppRoutes.home),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              Text('Register', style: context.h1),
              const SizedBox(height: 6),
              Text(
                'Enter your details below to create your account',
                style: context.bodyMuted,
              ),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
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
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
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
                    activeColor: scheme.primary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: colors.text),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              color: colors.text,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              color: colors.text,
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
              PrimaryButton(
                text: 'Register',
                onPressed: _busy ? null : _register,
                loading: _registerLoading,
              ),

              PlatformSocialSection(
                loading: _busy,
                googleLoading: _googleLoading,
                onGoogle: _googleSignIn,
                onApple: () =>
                    showAppSnack(context, 'Apple signup coming soon.'),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: context.bodyMuted),
                  GestureDetector(
                    onTap: () => context.push(
                      '${AppRoutes.login}?email=${Uri.encodeComponent(_email.text.trim().toLowerCase())}',
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
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
