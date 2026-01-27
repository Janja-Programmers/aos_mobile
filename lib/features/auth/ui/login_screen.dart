import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/ui/verify_otp_screen.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/platform_social_section.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

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
  bool _obscure = true;
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
    if (_busy) return;
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

      await result.fold((f) async {
        showAppSnack(context, f.message);

        final msg = f.message.toLowerCase();
        final email = _emailCtrl.text.trim().toLowerCase();

        if (msg.contains('verify your email')) {
          await context.push(
            AppRoutes.verifyOtp,
            extra: {'email': email, 'purpose': OtpPurpose.emailVerification},
          );
          return;
        }
      }, (_) async => context.go(AppRoutes.home));
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loginLoading = false);
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
              Text('Hello, Welcome Back', style: context.h1),
              const SizedBox(height: 6),
              Text('Login to your account below', style: context.bodyMuted),
              const SizedBox(height: 26),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      validator: Validators.passwordRequired,
                      onFieldSubmitted: (_) => _login(),
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
                  ),
                  Expanded(
                    child: Text(
                      'Remember Me',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: colors.text),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: colors.muted),
                    ),
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
                    showAppSnack(context, 'Apple signup coming soon.'),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? ', style: context.bodyMuted),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: Text(
                      'Register',
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
