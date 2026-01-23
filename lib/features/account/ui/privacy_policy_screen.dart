import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/features/account/ui/legal_docs_widgets.dart';

/// Simple static Privacy Policy page.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [const PrivacyPolicyContent()],
      ),
    );
  }
}
