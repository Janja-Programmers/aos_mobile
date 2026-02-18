import 'dart:async';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';

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

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = widget.initialSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _handleResend() {
    widget.onResend();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't receive the code? ", style: context.p),

        if (_canResend)
          GestureDetector(
            onTap: _handleResend,
            child: Text('Resend', style: context.pStrong),
          )
        else
          Text('Resend in ${_secondsLeft}s', style: context.pMuted),
      ],
    );
  }
}
