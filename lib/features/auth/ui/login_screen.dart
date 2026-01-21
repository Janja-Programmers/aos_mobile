import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';

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
  bool _loading = false;

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

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailCtrl.text.trim().toLowerCase(),
            password: _passwordCtrl.text,
            rememberMe: _rememberMe,
          );

      if (!mounted) return;

      if (ok) {
        context.go(AppRoutes.home);
        return;
      }

      final err = ref.read(authControllerProvider).errorMessage;
      _snack(err ?? 'Login failed.');
    } catch (e) {
      if (!mounted) return;
      _snack('Network error: $e');
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
              Text('Hello, Welcome Back', style: AppTheme.h1(context)),
              const SizedBox(height: 6),
              Text(
                'Login to your account below',
                style: AppTheme.bodyMuted(context),
              ),
              const SizedBox(height: 26),

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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: AppTheme.inputDecoration(
                        label: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
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
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      'Remember Me',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: AppColors.text),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: implement forgot password flow
                      _snack('Forgot password is coming soon.');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              AppTheme.primaryButton(
                text: 'Login',
                onPressed: _loading ? null : _login,
                loading: _loading,
              ),

              const SizedBox(height: 18),
              Row(
                children: const [
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

              // Social buttons (placeholders)
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
                    'Don\'t have an account? ',
                    style: AppTheme.bodyMuted(context),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: const Text(
                      'Register',
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
