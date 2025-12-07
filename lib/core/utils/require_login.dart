import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/screens/auth/auth_provider.dart';

Future<bool> requireLogin(BuildContext context) async {
  final auth = context.read<AuthProvider>();

  if (auth.isLoggedIn) {
    return true;
  }

  // Not logged in → send user to login
  final current = GoRouterState.of(context).uri.toString();
  auth.setReturnTo(current);

  context.push('/login');

  return false;
}
