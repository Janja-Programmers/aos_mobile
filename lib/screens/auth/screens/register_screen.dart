import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/validators.dart';

import '../auth_provider.dart';
import '../controllers/register_controller.dart';
import '../widgets/app_input.dart';
import '../widgets/text_widget.dart';
import '../widgets/privacy_policy_dialog.dart';
import '../widgets/terms_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController numCtrl = TextEditingController();
  final TextEditingController userTypeCtrl = TextEditingController();

  bool obscurePass = true;
  bool isLoading = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset('assets/logo_transparent.png', height: 60),
                      const SizedBox(height: 10),
                      const Text(
                        'Create an account for',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Africa Online Stores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: userCtrl,
                    hint: "Jane Doe",
                    icon: Icons.person,
                    validator: AppValidator.isName,
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: emailCtrl,
                    hint: 'jane@example.com',
                    icon: Icons.email,
                    validator: AppValidator.isEmail,
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.badge),
                      hintText: "Select User Type",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value:
                        userTypeCtrl.text.isNotEmpty ? userTypeCtrl.text : null,
                    items: const [
                      DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                      DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                    ],
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'User type is required'
                                : null,
                    onChanged: (value) {
                      setState(() => userTypeCtrl.text = value ?? '');
                    },
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: numCtrl,
                    hint: "0700123456",
                    icon: Icons.phone,
                    inputType: TextInputType.phone,
                    validator: AppValidator.isPhone,
                  ),
                  const SizedBox(height: 10),

                  AppInputField(
                    controller: passCtrl,
                    hint: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscure: obscurePass,
                    toggle: () => setState(() => obscurePass = !obscurePass),
                    validator: AppValidator.isPassword,
                  ),

                  const SizedBox(height: 10),

                  AppInputField(
                    controller: confirmPassCtrl,
                    hint: 'Confirm Password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscure: obscurePass,
                    toggle: () => setState(() => obscurePass = !obscurePass),
                    validator: AppValidator.isConfirmPassword,
                  ),

                  const SizedBox(height: 12),

                  FormField<bool>(
                    initialValue: _acceptTerms,
                    validator: (value) {
                      if (value != true) {
                        return 'You must accept Terms & Conditions';
                      }
                      return null;
                    },
                    builder: (formFieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (val) {
                                  setState(() {
                                    _acceptTerms = val ?? false;
                                    formFieldState.didChange(_acceptTerms);
                                  });
                                },
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    const Text(
                                      "I agree to the ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showTermsDialog(
                                          context,
                                          onAcceptCheck: () {
                                            setState(() {
                                              _acceptTerms = true;
                                            });
                                            formFieldState.didChange(true);
                                          },
                                        );
                                      },

                                      child: const Text(
                                        "Terms & Conditions",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const Text(" and "),
                                    GestureDetector(
                                      onTap:
                                          () => showPrivacyPolicyDialog(
                                            context,
                                            onAccept: () {
                                              setState(
                                                () => _acceptTerms = true,
                                              );
                                              formFieldState.didChange(true);
                                            },
                                          ),
                                      child: const Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (formFieldState.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 2),
                              child: Text(
                                formFieldState.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : () => RegisterController.signUp(
                                context: context,
                                auth: auth,
                                formKey: _formKey,
                                userCtrl: userCtrl,
                                emailCtrl: emailCtrl,
                                passCtrl: passCtrl,
                                confirmPassCtrl: confirmPassCtrl,
                                phoneCtrl: numCtrl,
                                userTypeCtrl: userTypeCtrl,
                                onStart: () => setState(() => isLoading = true),
                                onEnd: () => setState(() => isLoading = false),
                              ),
                      child: Text(
                        isLoading ? 'Verifying...' : 'Sign Up',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text(
                      "Have an account? Login",
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
