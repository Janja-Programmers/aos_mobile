import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/theme/app_theme_extensions.dart';
import 'package:aos_mobile/features/account/ui/legal_docs_widgets.dart';

/// Simple static Terms & Conditions page.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback if opened via deep link
              context.go('/');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [const TermsConditionsContent()],
      ),
    );
  }
}
