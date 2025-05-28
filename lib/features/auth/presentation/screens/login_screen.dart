import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: userCtrl,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          TextField(
            controller: passCtrl,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('Login button pressed');
              await auth.login(userCtrl.text, passCtrl.text);
              print('Login finished');

              if (!mounted) return;

              if (auth.user != null) {
                print('User is valid, navigating to products');
                context.go('/products');
              } else {
                print('Login failed, user is null');
              }
            },

            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
