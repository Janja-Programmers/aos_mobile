import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';

import '../auth_provider.dart';

class RegisterController {
  static Future<void> signUp({
    required BuildContext context,
    required AuthProvider auth,
    required GlobalKey<FormState> formKey,
    required TextEditingController userCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController userTypeCtrl,
    required VoidCallback onStart,
    required VoidCallback onEnd,
  }) async {
    if (!formKey.currentState!.validate()) return;

    final password = passCtrl.text.trim();
    final confirm = confirmPassCtrl.text.trim();
    if (password.length < 6) {
      topSnackBar(
        context,
        'Password must be at least 6 characters.',
        type: TopSnackType.error,
      );
      return;
    }

    if (password != confirm) {
      topSnackBar(context, 'Passwords do not match.', type: TopSnackType.error);
      return;
    }

    onStart();

    final success = await auth.signUp(
      emailCtrl.text.trim(),
      userCtrl.text.trim(),
      userTypeCtrl.text.trim(),
      phoneCtrl.text.trim(),
      password,
    );

    onEnd();

    void clearForm() {
      for (final c in [
        userCtrl,
        emailCtrl,
        phoneCtrl,
        passCtrl,
        confirmPassCtrl,
        userTypeCtrl,
      ]) {
        c.clear();
      }
    }

    if (success) {
      if (context.mounted) {
        clearForm();

        if (auth.registerStatus != 0) {
          await Future.delayed(const Duration(seconds: 1));
          context.go(
            '/login?from=register&msg=${Uri.encodeComponent(auth.registerSuccess ?? "Registration successful!")}',
          );
        }
      }
    } else {
      if (context.mounted && auth.registerError != null) {
        topSnackBar(context, auth.registerError!, type: TopSnackType.error);
      }
    }
  }
}
