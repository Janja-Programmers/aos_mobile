import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/core/constants/colors.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/app_input.dart';
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
                      await auth.register(userCtrl.text, passCtrl.text);
                      context.push('/login');
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
