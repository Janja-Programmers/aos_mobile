import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Column(
        children: [
          TextField(
            controller: userCtrl,
            decoration: const InputDecoration(hintText: 'Username'),
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.register(userCtrl.text, passCtrl.text);
              context.push('/login');
            },
            child: const Text('Register'),
          ),

          ElevatedButton(
            onPressed: () {
              context.push('/dashboard');
            },
            child: const Text('Dashboard'),
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
