import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          CircleAvatar(
            radius: 60,
            backgroundColor: colors.primary.withOpacity(0.1),
            child: Icon(Icons.shopping_bag, size: 64, color: colors.primary),
          ),

          const SizedBox(height: 32),

          Text(
            "Welcome to Africa Online Stores",
            style: context.h3,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            "Buy and sell across Africa. Let's set up a few things first.",
            style: context.pMuted,
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          PrimaryButton(text: "Get Started", onPressed: onContinue),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
