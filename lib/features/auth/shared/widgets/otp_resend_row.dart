import 'package:flutter/material.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    super.key,
    required this.resending,
    required this.onResend,
  });

  final bool resending;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't receive the code? ", style: context.bodyMuted),
        GestureDetector(
          onTap: onResend,
          child: Text(
            resending ? 'Sending...' : 'Resend',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
