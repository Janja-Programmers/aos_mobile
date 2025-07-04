import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/core/utils/logger.dart';
import 'package:ownashop/features/auth/presentation/widgets/app_input.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
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
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
                    'Login to Own A Shop',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Username or email
                  CustomTextField(
                    controller: userCtrl,
                    hint: 'Email',
                    icon: Icons.person,
                    inputType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your email'
                                : null,
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
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add forgot password logic
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleLogin(auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isLoading ? 'Verifying...' : 'Log in',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('or'),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Email link login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFEFEF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login with Email Link',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await auth.login(userCtrl.text.trim(), passCtrl.text.trim());

    result.fold(
      (failure) {
        setState(() {
          _error =
              failure.hashCode == 401
                  ? 'Invalid email or password'
                  : 'An error occurred! Please try again.';
        });
      },
      (_) {
        final goTo = auth.consumeReturnTo();
        appLogger.i('✅ Navigating to: $goTo from login screen');
        context.go(goTo);
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
