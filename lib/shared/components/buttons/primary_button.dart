import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              )
            : Text(text, style: context.button),
      ),
    );
  }
}
