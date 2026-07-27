import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class OnboardingSelectionLayout extends StatelessWidget {
  const OnboardingSelectionLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.field,
    required this.primaryText,
    required this.onPrimary,
    required this.secondaryText,
    required this.onSecondary,
    this.convenienceAction,
    this.showBack = false,
    this.onBack,
    this.primaryLoading = false,
    this.error,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget field;
  final Widget? convenienceAction;
  final String primaryText;
  final VoidCallback? onPrimary;
  final String secondaryText;
  final VoidCallback? onSecondary;
  final bool showBack;
  final VoidCallback? onBack;
  final bool primaryLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            sliver: SliverList.list(
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
                const SizedBox(height: 12),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(icon, size: 54, color: scheme.primary),
                  ),
                ),
                const SizedBox(height: 22),
                Text(title, style: context.h4, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: context.pMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                field,
                if (convenienceAction != null) ...<Widget>[
                  const SizedBox(height: 12),
                  convenienceAction!,
                ],
                if (error?.trim().isNotEmpty ?? false) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: context.p.copyWith(color: colors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 28),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  PrimaryButton(
                    text: primaryText,
                    loading: primaryLoading,
                    onPressed: onPrimary,
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: primaryLoading ? null : onSecondary,
                    child: Text(secondaryText, style: context.pMuted),
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
