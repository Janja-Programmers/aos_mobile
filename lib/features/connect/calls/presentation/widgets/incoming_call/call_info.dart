import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CallInfo extends StatelessWidget {
  final String name;
  final String subtitle;

  const CallInfo({super.key, required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    // final colors = context.appColors;

    return Column(
      children: [
        Text(
          name,
          style: context.body.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(subtitle, style: context.pMuted.copyWith(fontSize: 20)),
      ],
    );
  }
}
