import 'package:aos_mobile/core/api/api_endpoints.dart';
import 'package:aos_mobile/core/const.dart';
import 'package:flutter/material.dart';

import 'core/api/api_client.dart';

import 'features/auth/data/auth_api.dart';
import 'features/auth/ui/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseUrl = ApiEndpoints.baseUrl;
    final apiClient = ApiClient(baseUrl);
    final authApi = AuthApi(apiClient);

    return MaterialApp(
      title: AppStrings.title,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(authApi: authApi),
    );
  }
}
