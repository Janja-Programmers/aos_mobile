import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class OnboardingNetworkState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback? onPrimary;
  final String secondaryText;
  final VoidCallback? onSecondary;
  final bool primaryLoading;
  final bool showBack;
  final VoidCallback? onBack;

  const OnboardingNetworkState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.onPrimary,
    required this.secondaryText,
    required this.onSecondary,
    this.primaryLoading = false,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
              ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: scheme.primary.withOpacity(0.1),
                        child: Icon(icon, size: 56, color: scheme.primary),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        title,
                        style: context.h4,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        message,
                        style: context.pMuted,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: primaryText,
                        loading: primaryLoading,
                        onPressed: primaryLoading ? null : onPrimary,
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: primaryLoading ? null : onSecondary,
                        child: Text(secondaryText, style: context.pMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
