import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/auth/shared/widgets/otp_input.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class OtpSection extends StatefulWidget {
  const OtpSection({
    super.key,
    required this.header,
    required this.subtitle,
    required this.email,
    required this.enabled,
    required this.onChanged,
    required this.onCompleted,
    this.showCustomKeypad = true,
  });

  final String header;
  final String subtitle;
  final String email;

  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  final bool showCustomKeypad;

  @override
  State<OtpSection> createState() => _OtpSectionState();
}

class _OtpSectionState extends State<OtpSection> {
  final OtpInputController _otpController = OtpInputController(length: 6);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Column(
      children: [
        const SizedBox(height: 6),
        Center(
          child: Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
            ),
            child: Center(
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Icon(
                  Icons.mail_outline,
                  color: context.appColors.border,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text(widget.header, style: context.h4)),
        const SizedBox(height: 10),
        Center(child: Text(widget.subtitle, style: context.p)),
        const SizedBox(height: 6),
        Center(
          child: Text(
            widget.email,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 22),

        // OTP input (handles paste, delete, selection, and optional custom keypad)
        OtpInput(
          controller: _otpController,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onCompleted: widget.onCompleted,
          showCustomKeypad: widget.showCustomKeypad,
        ),
      ],
    );
  }
}
