import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utils/snackbar.dart';
import '../../screens/auth/auth_provider.dart';

class ConfirmDeleteAccountDialog extends StatefulWidget {
  const ConfirmDeleteAccountDialog({super.key});

  /// Shows the dialog
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ConfirmDeleteAccountDialog(),
    );
  }

  @override
  State<ConfirmDeleteAccountDialog> createState() =>
      _ConfirmDeleteAccountDialogState();
}

class _ConfirmDeleteAccountDialogState
    extends State<ConfirmDeleteAccountDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    // ✅ no password argument anymore
    final result = await authProvider.deleteAccount();

    result.fold(
      (failure) {
        topSnackBar(context, failure.message, type: TopSnackType.error);
        setState(() => _isLoading = false);
      },
      (message) async {
        // Clear local session & app state
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        topSnackBar(context, message, type: TopSnackType.success);

        if (!mounted) return;

        // Close dialog, logout and redirect
        context.pop();
        await authProvider.logout();
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
        "This will permanently delete your account and all data.\n"
        "This action cannot be undone. Are you sure you want to continue?",
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isLoading ? null : _handleDelete,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text("Yes, Delete"),
        ),
      ],
    );
  }
}
