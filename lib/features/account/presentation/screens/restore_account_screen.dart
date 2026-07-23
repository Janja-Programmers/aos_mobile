import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _requested = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() => _loading = true);
    final res = await ref
        .read(accountLifecycleApiProvider)
        .requestRestore(email: _emailController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    res.fold((f) => ShowSnack(context, f.message).error(), (msg) {
      setState(() => _requested = true);
      ShowSnack(context, msg).success();
    });
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    final res = await ref
        .read(accountLifecycleApiProvider)
        .restoreAccount(email: _emailController.text, otp: _otpController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    res.fold((f) => ShowSnack(context, f.message).error(), (msg) {
      ShowSnack(context, msg).success();
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Restore account', style: context.h5)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text('Restore deleted account', style: context.h4),
            const SizedBox(height: 8),
            Text(
              'Enter your email. If your account can be restored, we will send a verification code.',
              style: context.pMuted,
            ),
            const SizedBox(height: 18),
            TextField(
              key: const Key('restore_account_email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            if (_requested) ...[
              const SizedBox(height: 12),
              TextField(
                key: const Key('restore_account_otp_field'),
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Restore code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 22),
            ElevatedButton(
              key: const Key('restore_account_submit_button'),
              onPressed: _loading ? null : (_requested ? _restore : _request),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _requested ? 'Restore account' : 'Send restore code',
                      style: AppTextStylesX(context).button,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
