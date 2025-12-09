import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/snackbar.dart';
import '/core/utils/validators.dart';

import '../auth_provider.dart';

import '../widgets/text_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo_transparent.png', height: 80),
                  const SizedBox(height: 10),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Email input
                  CustomTextField(
                    controller: emailCtrl,
                    hint: 'Email Address',
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                    validator: (value) => AppValidator.isEmail(value),
                  ),

                  const SizedBox(height: 20),

                  // Reset password button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          auth.isLoading
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) return;

                                final success = await auth.forgotPassword(
                                  emailCtrl.text.trim(),
                                );

                                if (success) {
                                  topSnackBar(
                                    context,
                                    auth.forgotPasswordSuccess ??
                                        'Instructions sent',
                                    type: TopSnackType.success,
                                  );
                                  context.go('/login');
                                } else {
                                  topSnackBar(
                                    context,
                                    auth.forgotPasswordError ??
                                        'Something went wrong',
                                    type: TopSnackType.error,
                                  );
                                }
                              },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        auth.isLoading ? 'Sending...' : 'Reset Password',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
