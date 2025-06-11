import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '../auth_provider.dart';
import '../widgets/app_input.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/text_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController numCtrl = TextEditingController();
  final TextEditingController userTypeCtrl = TextEditingController();

  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // light gray background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/logo_transparent.png', height: 80),
                const SizedBox(height: 10),

                const Text(
                  'Create a Own A Shop Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: userCtrl,
                  hint: "Jane Doe",
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: emailCtrl,
                  hint: 'jane@example.com',
                  icon: Icons.email,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    prefixIcon: const Icon(Icons.badge),
                    hintText: "Select User Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value:
                      userTypeCtrl.text.isNotEmpty ? userTypeCtrl.text : null,
                  items: const [
                    DropdownMenuItem(value: 'Vendor', child: Text('Vendor')),
                    DropdownMenuItem(value: 'Buyer', child: Text('Buyer')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      userTypeCtrl.text = value!;
                    });
                  },
                ),

                const SizedBox(height: 12),

                CustomTextField(
                  controller: numCtrl,
                  hint: "0700123456",
                  icon: Icons.phone,
                  inputType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                AppInputField(
                  controller: passCtrl,
                  hint: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  obscure: obscurePass,
                  toggle: () => setState(() => obscurePass = !obscurePass),
                ),

                const SizedBox(height: 12),

                AppInputField(
                  controller: confirmPassCtrl,
                  hint: 'Confirm Password',
                  icon: Icons.lock,
                  isPassword: true,
                  obscure: obscurePass,
                  toggle: () => setState(() => obscurePass = !obscurePass),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

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
                    onPressed: () async {
                      final username = userCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final fullName = userCtrl.text.trim();
                      final userType = userTypeCtrl.text.trim();
                      final phone = numCtrl.text.trim();
                      final password = passCtrl.text.trim();

                      if (username.isEmpty ||
                          email.isEmpty ||
                          fullName.isEmpty ||
                          userType.isEmpty ||
                          phone.isEmpty ||
                          password.isEmpty) {
                        CustomSnackbar.showTopSnackbar(
                          context,
                          'Please fill all fields.',
                        );
                        return;
                      }

                      if (password != confirmPassCtrl.text.trim()) {
                        CustomSnackbar.showTopSnackbar(
                          context,
                          'Passwords do not match.',
                        );
                        return;
                      }
                      try {
                        final result = await auth.register(
                          username,
                          email,
                          fullName,
                          userType,
                          phone,
                          password,
                        );

                        if (!context.mounted) return;

                        final messageList = result['message'];
                        if (messageList is List && messageList.length > 1) {
                          final statusCode = messageList[0];
                          // final messageText = messageList[1];

                          if (statusCode == 0) {
                            // Already Registered
                            CustomSnackbar.showTopSnackbar(
                              context,
                              'User already registered.',
                            );
                          } else if (statusCode == 1) {
                            // Email verification required
                            CustomSnackbar.showTopSnackbar(
                              context,
                              'Please verify your email before logging in.',
                            );
                          } else if (statusCode == 2) {
                            // Successful registration
                            CustomSnackbar.showTopSnackbar(
                              context,
                              'Registration successful!',
                            );

                            context.push('/dashboard');
                          } else {
                            // Unknown status code
                            CustomSnackbar.showTopSnackbar(
                              context,
                              'Unexpected status: $statusCode',
                            );
                          }
                        } else {
                          CustomSnackbar.showTopSnackbar(
                            context,
                            'Invalid response from server.',
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        CustomSnackbar.showTopSnackbar(
                          context,
                          'Registration failed: $e',
                        );
                      }
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text("Have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    emailCtrl.dispose();
    numCtrl.dispose();
    userTypeCtrl.dispose();
    super.dispose();
  }
}
