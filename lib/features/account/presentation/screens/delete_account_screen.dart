import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmationController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_confirmationController.text.trim() != 'DELETE') {
      ShowSnack(context, 'Type DELETE to confirm.').error();
      return;
    }

    setState(() => _loading = true);
    final res = await ref
        .read(accountLifecycleApiProvider)
        .deleteAccount(
          confirmation: _confirmationController.text,
          reason: _reasonController.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    res.fold((f) => ShowSnack(context, f.message).error(), (msg) async {
      ShowSnack(context, msg).success();
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Delete account', style: context.h5)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Icon(Icons.warning_amber_rounded, size: 56, color: colors.red),
            const SizedBox(height: 14),
            Text('This is recoverable for a limited time.', style: context.h5),
            const SizedBox(height: 8),
            Text(
              'Deleting your account hides your profile and disables login. You can restore it by email verification within the backend restore window.',
              style: context.pMuted,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _reasonController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                labelText: 'Type DELETE',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: colors.red),
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: const Text('Delete my account'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.pushNamed(AppRoutes.nRestoreAccount),
              child: const Text('Restore a deleted account'),
            ),
          ],
        ),
      ),
    );
  }
}
