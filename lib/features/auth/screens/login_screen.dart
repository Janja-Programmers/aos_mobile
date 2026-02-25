import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/platform_social_section.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.prefillEmail});
  final String? prefillEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _rememberMe = true;
  bool _loginLoading = false;
  bool _googleLoading = false;

  bool get _busy => _loginLoading || _googleLoading;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // If email was provided by route query, use it; otherwise load remember-me.
    if (widget.prefillEmail != null && widget.prefillEmail!.trim().isNotEmpty) {
      _emailCtrl.text = widget.prefillEmail!.trim();
      return;
    }

    final (remember, email) = await ref
        .read(authControllerProvider.notifier)
        .getRememberedLogin();

    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      _emailCtrl.text = email;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loginLoading = true);

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailCtrl.text.trim().toLowerCase(),
            password: _passwordCtrl.text,
            rememberMe: _rememberMe,
          );

      if (!mounted) return;

      await result.fold(
        (f) async {
          ShowSnack(context, f.message).error();

          final msg = f.message.toLowerCase();
          final email = _emailCtrl.text.trim().toLowerCase();

          if (msg.contains('verify your email')) {
            // Navigate to OTP verification
            await context.pushNamed(
              AppRoutes.nVerifyOtp,
              extra: {'email': email, 'purpose': OtpPurpose.emailVerification},
            );

            // Set loading off after navigation
            if (mounted) setState(() => _loginLoading = false);
            return;
          }
        },
        (_) async {
          // Navigate to Home
          context.goNamed(AppRoutes.nHome);

          // Set loading off after navigation
          if (mounted) setState(() => _loginLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error: $e').error();
    } finally {
      // Only set loading off if navigation didn’t happen
      if (mounted && _loginLoading) setState(() => _loginLoading = false);
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
        (f) => ShowSnack(context, f.message).error(),
        (_) => context.goNamed(AppRoutes.nHome),
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error: $e').error();
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
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
              Text('Hello, Welcome Back', style: context.h1),
              const SizedBox(height: 6),
              Text('Login to your account below', style: context.p),
              const SizedBox(height: 26),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email Address',
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppPasswordFormField(
                      controller: _passwordCtrl,
                      validator: Validators.passwordRequired,
                      onFieldSubmitted: (_) => _login(),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    activeColor: scheme.primary,
                    checkColor: scheme.tertiary,
                  ),
                  Expanded(child: Text('Remember Me', style: context.p)),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(AppRoutes.nForgotPassword);
                    },
                    child: Text('Forgot Password?', style: context.p),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'Login',
                onPressed: _busy ? null : _login,
                loading: _loginLoading,
              ),
              PlatformSocialSection(
                loading: _busy,
                googleLoading: _googleLoading,
                onGoogle: _googleSignIn,
                onApple: () =>
                    ShowSnack(context, 'Apple signup coming soon.').info(),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? ', style: context.p),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoutes.nRegister),
                    child: Text('Register', style: context.pStrong),
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
