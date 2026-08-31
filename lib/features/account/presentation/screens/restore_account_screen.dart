import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key, this.prefillEmail});

  final String? prefillEmail;

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final String email = widget.prefillEmail?.trim().toLowerCase() ?? '';
    if (email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    setState(() => _loading = true);

    try {
      final result = await ref
          .read(accountLifecycleApiProvider)
          .requestRestore(email: email);

      if (!mounted) return;

      result.fold((failure) => ShowSnack(context, failure.message).error(), (
        message,
      ) {
        ShowSnack(context, message).success();
        context.pushNamed(
          AppRoutes.nVerifyOtp,
          extra: {'email': email, 'purpose': OtpPurpose.accountRestore},
        );
      });
    } catch (error) {
      if (!mounted) return;
      ShowSnack(
        context,
        context.l10n.auth_unexpected_error(error.toString()),
      ).error();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            Text('Restore account', style: context.h3),
            const SizedBox(height: 8),
            Text(
              'Enter your email. If your account can be restored, we will send a verification code.',
              style: context.p,
            ),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppFormField(
                    key: const Key('auth.restore.email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    label: l10n.auth_email_address,
                    validator: Validators.email,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _request(),
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    key: const Key('auth.restore.submit'),
                    text: l10n.auth_send_otp,
                    onPressed: _loading ? null : _request,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
