import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utils/snackbar.dart';

import '../auth/auth_provider.dart';

class ConfirmDeleteAccountDialog extends StatelessWidget {
  const ConfirmDeleteAccountDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDeleteAccountDialog(),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text("Delete Account"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "This will permanently delete your account and all data.\n"
            "This action cannot be undone. Enter your password to confirm.",
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text("Cancel"),
        ),
        StatefulBuilder(
          builder: (ctx, setState) {
            bool isLoading = false;

            Future<void> handleDelete() async {
              setState(() => isLoading = true);

              final authProvider = context.read<AuthProvider>();
              final result = await authProvider.deleteAccount(
                passwordController.text,
              );

              result.fold(
                (failure) {
                  topSnackBar(
                    context,
                    failure.message,
                    type: TopSnackType.error,
                  );
                },
                (message) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // ✅ clear all local session data

                  topSnackBar(context, message, type: TopSnackType.success);

                  context.pop(true); // triggers logout+redirect
                },
              );

              setState(() => isLoading = false);
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isLoading ? null : handleDelete,
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text("Yes, Delete"),
            );
          },
        ),
      ],
    );
  }
}
