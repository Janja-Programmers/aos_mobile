import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

class AppSuccessSheet extends StatelessWidget {
  const AppSuccessSheet({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  static const BorderRadius _sheetRadius = BorderRadius.vertical(
    top: Radius.circular(26),
  );
  static const double _maxHeightFactor = 0.85;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final viewPadding = mediaQuery.viewPadding;
    final size = mediaQuery.size;

    final maxHeight = size.height * _maxHeightFactor;

    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              22,
              22,
              22,
              22 + viewPadding.bottom + viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: _sheetRadius,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appColors.fieldBg,
                    ),
                    child: Center(
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                        child: Icon(Icons.check, color: scheme.onPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: context.h2, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: context.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(text: buttonText, onPressed: onPressed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
