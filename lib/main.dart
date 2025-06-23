import 'package:flutter/material.dart';

import 'features/auth/presentation/auth_provider.dart';

import 'core/di/service_locator.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up your GetIt DI
  await init();

  // Load user before launching UI
  final auth = sl<AuthProvider>();
  await auth.loadUser();

  // Launch app
  runApp(App(auth: auth));
}
