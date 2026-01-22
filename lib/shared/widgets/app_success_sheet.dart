import 'package:flutter/material.dart';

import 'package:aos_mobile/core/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F1F2),
            ),
            child: Center(
              child: Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTheme.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTheme.bodyMuted(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          AppTheme.primaryButton(
            text: buttonText,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
