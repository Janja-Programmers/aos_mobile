import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class OtpResendRow extends StatefulWidget {
  const OtpResendRow({
    super.key,
    required this.onResend,
    this.initialSeconds = 25,
  });

  final VoidCallback onResend;
  final int initialSeconds;

  @override
  State<OtpResendRow> createState() => _OtpResendRowState();
}

class _OtpResendRowState extends State<OtpResendRow> {
  late int _secondsLeft;
  Timer? _timer;

  bool get _canResend => _secondsLeft == 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown({bool rebuild = false}) {
    _timer?.cancel();

    if (rebuild) {
      setState(() => _secondsLeft = widget.initialSeconds);
    } else {
      _secondsLeft = widget.initialSeconds;
    }

    if (_secondsLeft == 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }

      setState(() => _secondsLeft--);
    });
  }

  void _handleResend() {
    widget.onResend();
    _startCountdown(rebuild: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.auth_resend_code,
          style: context.p.copyWith(color: context.appColors.primary),
        ),

        if (_canResend)
          GestureDetector(
            onTap: _handleResend,
            child: Text(l10n.auth_resend, style: context.pStrong),
          )
        else
          Text(
            '${l10n.auth_resend_in} ${_secondsLeft}s',
            style: context.pMuted,
          ),
      ],
    );
  }
}
