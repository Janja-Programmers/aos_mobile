import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PrimaryShortButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryShortButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        child: Text(
          label,
          style: context.p.copyWith(color: context.appColors.white),
        ),
      ),
    );
  }
}
