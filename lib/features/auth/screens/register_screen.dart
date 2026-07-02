import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/validators.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/platform_social_section.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/shared/widgets/legal_docs_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _appleLoading = false;
  bool _registerLoading = false;
  bool _accept = true;

  bool get _busy => _registerLoading || _googleLoading || _appleLoading;

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

    unawaited(
      showModalBottomSheet<void>(
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
                          color: colors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text(title, style: context.h2)),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: context.appColors.border,
                            ),
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
      ),
    );
  }

  Future<void> _register() async {
    final l10n = context.l10n;

    if (!_accept) {
      if (mounted) {
        ShowSnack(context, l10n.auth_accept_terms_error).error();
      }
      return;
    }

    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _registerLoading = true);

    try {
      final prefs = ref.read(userPreferenceControllerProvider);

      final result = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim().toLowerCase(),
            password: _password.text,
            fullName: _name.text.trim(),
            country: prefs.countryCode,
            language: prefs.languageCode,
            currency: prefs.currencyCode,
          );

      if (!mounted) return;

      await result.fold(
        (f) async => ShowSnack(
          context,
          l10n.auth_unexpected_error(f.message.toString()),
        ).error(),
        (msg) async {
          ShowSnack(context, msg).success();
          await context.pushNamed(
            AppRoutes.nVerifyOtp,
            extra: _email.text.trim().toLowerCase(),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, l10n.auth_unexpected_error(e.toString())).error();
    } finally {
      if (mounted) {
        setState(() => _registerLoading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    if (_busy) return;

    final l10n = context.l10n;

    final prefs = ref.read(userPreferenceControllerProvider);

    setState(() => _googleLoading = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(
            country: prefs.countryCode,
            language: prefs.languageCode,
            currency: prefs.currencyCode,
          );

      if (!mounted) return;

      result.fold(
        (f) => ShowSnack(context, f.message).error(),
        (_) => context.goNamed(AppRoutes.nHome),
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, l10n.auth_unexpected_error(e.toString())).error();
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
            country: prefs.countryCode,
            language: prefs.languageCode,
            currency: prefs.currencyCode,
          );

      if (!mounted) return;

      result.fold(
        (f) => ShowSnack(context, f.message).error(),
        (_) => context.goNamed(AppRoutes.nHome),
      );
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Unexpected error: $e').error();
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

              Text(l10n.auth_register_title, style: context.h1),
              const SizedBox(height: 6),

              Text(l10n.auth_register_subtitle, style: context.p),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppFormField(
                      controller: _name,
                      label: l10n.auth_full_name,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 16),

                    AppFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      label: l10n.auth_email_address,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppPasswordFormField(
                      controller: _password,
                      label: l10n.auth_confirm_password,
                      validator: Validators.passwordRequired,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 16),

                    AppPasswordFormField(
                      controller: _confirm,
                      label: l10n.auth_confirm_password,
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
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
                    checkColor: scheme.tertiary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: context.p,
                        children: [
                          TextSpan(text: l10n.auth_agree_prefix),
                          TextSpan(
                            text: l10n.auth_terms_and_conditions,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openLegalSheet(
                                title: l10n.auth_terms_and_conditions,
                                child: const TermsConditionsContent(),
                              ),
                          ),
                          TextSpan(text: l10n.auth_and),
                          TextSpan(
                            text: l10n.auth_privacy_policy,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openLegalSheet(
                                title: l10n.auth_privacy_policy,
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
                text: l10n.auth_register_button,
                onPressed: _busy ? null : _register,
                loading: _registerLoading,
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
                  Text(l10n.auth_already_have_account, style: context.p),
                  GestureDetector(
                    onTap: () => context.pushNamed(
                      AppRoutes.nLogin,
                      queryParameters: {
                        'email': _email.text.trim().toLowerCase(),
                      },
                    ),
                    child: Text(l10n.auth_login, style: context.pStrong),
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
