import 'package:flutter/material.dart';

import 'features/cart/provider.dart';
import 'features/auth/presentation/auth_provider.dart';

import 'core/di/service_locator.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up GetIt
  await init();

  // Load user
  final auth = sl<AuthProvider>();
  await auth.loadUser();

  // ✅ Load cart
  final cartProvider = sl<CartProvider>();
  await cartProvider.loadCart();

  // Run app
  runApp(App(auth: auth));
}
