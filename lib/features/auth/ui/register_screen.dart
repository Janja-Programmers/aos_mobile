import 'package:flutter/material.dart';
import '../data/auth_api.dart';
import 'aos_ui.dart';
import 'verify_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authApi});
  final AuthApi authApi;

  @override
  State<RegisterScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _accept = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_accept) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms & Conditions and Privacy Policy'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await widget.authApi.register(
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
        fullName: _name.text.trim(),
      );

      final ok = res['ok'] == true;
      final msg = (res['message'] ?? '').toString();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      if (ok) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOTPScreen(
              authApi: widget.authApi,
              email: _email.text.trim().toLowerCase(),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AOSUi.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView(
            children: [
              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 36,
                  width: 36,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Text('Register', style: AOSUi.h1(context)),
              const SizedBox(height: 6),
              Text(
                'Enter your details below to create your account',
                style: AOSUi.bodyMuted(context),
              ),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: AOSUi.inputDecoration(label: 'Full Name'),
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AOSUi.inputDecoration(label: 'Email Address'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Email is required';
                        if (!t.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure1,
                      decoration: AOSUi.inputDecoration(
                        label: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Min 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure2,
                      decoration: AOSUi.inputDecoration(
                        label: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) => (v != _password.text)
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _accept,
                    onChanged: (v) => setState(() => _accept = v ?? false),
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      'I Accept the Terms & Conditions and Privacy Policy',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: AOSUi.text),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              AOSUi.primaryButton(
                text: 'Register',
                onPressed: _signup,
                loading: _loading,
              ),

              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(child: Divider(color: AOSUi.stroke)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or Register with',
                      style: TextStyle(color: AOSUi.muted),
                    ),
                  ),
                  Expanded(child: Divider(color: AOSUi.stroke)),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  AOSUi.socialButton(
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.red,
                    ),
                    text: 'Google',
                    onTap: () {
                      // TODO: later
                    },
                  ),
                  const SizedBox(width: 12),
                  AOSUi.socialButton(
                    icon: const Icon(
                      Icons.apple,
                      size: 22,
                      color: Colors.black,
                    ),
                    text: 'Apple',
                    onTap: () {
                      // TODO: later
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Do you have an account? ',
                    style: AOSUi.bodyMuted(context),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to Signin screen later
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerifyOTPScreen(
                            authApi: widget.authApi,
                            email: _email.text.trim().toLowerCase(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
