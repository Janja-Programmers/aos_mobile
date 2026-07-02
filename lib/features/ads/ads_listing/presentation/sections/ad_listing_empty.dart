import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class AdListingEmptyView extends StatelessWidget {
  const AdListingEmptyView({
    super.key,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimaryAction,
    this.onLearnMore,
  });

  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.06),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: colors.textMuted,
              ),
            ),

            const SizedBox(height: 20),

            Text(title, style: context.h3),
            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: context.p.copyWith(color: colors.textMuted),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: primaryLabel,
              onPressed: onPrimaryAction,
              icon: Icons.add,
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: onLearnMore,
              child: Text(
                'Learn how to sell faster',
                style: context.p.copyWith(
                  color: colors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
