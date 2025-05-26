import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/constants/dimensions.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.login)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _emailController,
                label: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              CustomTextField(
                controller: _passwordController,
                label: AppStrings.password,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                    text: AppStrings.signIn,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        await Future.delayed(
                          const Duration(seconds: 1),
                        ); // Simulate API
                        setState(() => _isLoading = false);
                        context.push('/products');
                      }
                    },
                  ),
              const SizedBox(height: AppDimensions.paddingSmall),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text(AppStrings.noAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
