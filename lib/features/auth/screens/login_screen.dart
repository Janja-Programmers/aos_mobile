import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/platform_social_section.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.prefillEmail, this.redirectLocation});

  final String? prefillEmail;
  final String? redirectLocation;

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
  bool _appleLoading = false;

  bool get _busy => _loginLoading || _googleLoading || _appleLoading;

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
            identifier: _emailCtrl.text.trim().toLowerCase(),
            password: _passwordCtrl.text,
            rememberMe: _rememberMe,
          );

      // If the router-owned auth redirect already ran, this screen will have
      // been disposed and no imperative navigation is needed. Otherwise,
      // complete the successful login deterministically at the public landing
      // page. This does not alter guest routing or add a global login guard.
      if (!mounted) return;

      final failure = result.leftOrNull;
      if (failure == null) {
        context.go(AppRoutes.home);
        return;
      }

      final error = (failure.error ?? '').trim().toUpperCase();
      final identifier = _emailCtrl.text.trim().toLowerCase();

      if (error == 'ACCOUNT_DELETED_RESTORABLE') {
        await _startRestorableLogin(identifier);
        return;
      }

      ShowSnack(context, failure.message).error();

      if (error == 'EMAIL_NOT_VERIFIED') {
        await context.pushNamed(
          AppRoutes.nVerifyOtp,
          extra: {'email': identifier, 'purpose': OtpPurpose.emailVerification},
        );
      }
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Error').error();
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _startRestorableLogin(String identifier) async {
    // The restore-request contract accepts an email only. Login itself accepts
    // a broader identifier, so non-email identifiers fall back to the manual
    // restore entry screen instead of fabricating an email address.
    if (Validators.email(identifier) != null) {
      if (!mounted) return;
      context.goNamed(AppRoutes.nRestoreAccount);
      return;
    }

    final request = await ref
        .read(accountLifecycleApiProvider)
        .requestRestore(email: identifier);

    if (!mounted) return;

    final requestFailure = request.leftOrNull;
    if (requestFailure != null) {
      ShowSnack(context, requestFailure.message).error();
      return;
    }

    // Match the web flow: after password proof confirms that the account is
    // restorable, request the account_restore OTP and move directly to the
    // shared OTP screen. The request endpoint intentionally returns a generic
    // success message, so the stable login error is what authorizes this path.
    context.goNamed(
      AppRoutes.nVerifyOtp,
      extra: {'email': identifier, 'purpose': OtpPurpose.accountRestore},
    );
  }

  Future<void> _googleSignIn() async {
    if (_busy) return;
    final prefs = ref.read(userPreferenceControllerProvider);

    setState(() => _googleLoading = true);

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(
            country: prefs.countryId,
            language: prefs.languageId,
            currency: prefs.currencyId,
          );

      if (!mounted) return;

      result.fold((f) => ShowSnack(context, f.message).error(), (_) {});
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error').error();
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _appleSignIn() async {
    if (_busy) return;

    final prefs = ref.read(userPreferenceControllerProvider);

    setState(() => _appleLoading = true);

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signInWithApple(
            country: prefs.countryId,
            language: prefs.languageId,
            currency: prefs.currencyId,
          );

      if (!mounted) return;

      result.fold((f) => ShowSnack(context, f.message).error(), (_) {});
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error').error();
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

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

              Text(l10n.auth_login_title, style: context.h1),
              const SizedBox(height: 6),

              Text(l10n.auth_login_subtitle, style: context.p),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppFormField(
                      key: const Key('auth.login.identifier'),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email or phone',
                      validator: Validators.identifier,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppPasswordFormField(
                      key: const Key('auth.login.password'),
                      controller: _passwordCtrl,
                      label: l10n.auth_password,
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
                    key: const Key('auth.login.rememberMe'),
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    activeColor: scheme.primary,
                    checkColor: scheme.tertiary,
                  ),
                  Expanded(
                    child: Text(l10n.auth_remember_me, style: context.p),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(AppRoutes.nForgotPassword);
                    },
                    child: Text(l10n.auth_forgot_password, style: context.p),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              PrimaryButton(
                key: const Key('auth.login.submit'),
                text: l10n.auth_login_button,
                onPressed: _busy ? null : _login,
                loading: _loginLoading,
              ),

              PlatformSocialSection(
                loading: _busy,
                googleLoading: _googleLoading,
                appleLoading: _appleLoading,
                onGoogle: _googleSignIn,
                onApple: _appleSignIn,
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.auth_no_account, style: context.p),

                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoutes.nRegister),
                    child: Text(l10n.auth_register, style: context.pStrong),
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
