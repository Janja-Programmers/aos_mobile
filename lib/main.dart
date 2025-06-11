import 'package:flutter/material.dart';
import './app.dart';

// Items
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(App());
}
