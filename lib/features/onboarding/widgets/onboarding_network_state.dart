import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class OnboardingNetworkState extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  if (showBack)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: scheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                icon,
                                size: 50,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 22),
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
          ),
        ],
      ),
    );
  }
}
