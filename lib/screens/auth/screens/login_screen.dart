import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/snackbar.dart';
import '/core/utils/validators.dart';

import '../auth_provider.dart';

import '../widgets/app_input.dart';
import '../widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
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
                    'Login to Africa Online Stores',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Username or email
                  CustomTextField(
                    controller: userCtrl,
                    hint: 'Email',
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                    validator: (value) => AppValidator.isEmail(value),
                  ),

                  const SizedBox(height: 12),

                  // Password
                  AppInputField(
                    controller: passCtrl,
                    hint: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscure: obscurePass,
                    toggle: () => setState(() => obscurePass = !obscurePass),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your password'
                                : null,
                    textInputAction: TextInputAction.done,
                  ),

                  // const SizedBox(height: 10),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // Add forgot password logic
                  //     },
                  //     child: const Text(
                  //       'Forgot Password?',
                  //       style: TextStyle(fontSize: 13),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          auth.isLoading
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) return;

                                final success = await auth.signIn(
                                  userCtrl.text.trim(),
                                  passCtrl.text.trim(),
                                );

                                if (success) {
                                  context.go(auth.consumeReturnTo());
                                } else {
                                  if (context.mounted &&
                                      auth.loginError != null) {
                                    topSnackBar(
                                      context,
                                      auth.loginError!,
                                      type: TopSnackType.error,
                                    );
                                  }
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
                        auth.isLoading ? 'Verifying...' : 'Log in',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text(
                      "Don't have an account? Sign up",
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
