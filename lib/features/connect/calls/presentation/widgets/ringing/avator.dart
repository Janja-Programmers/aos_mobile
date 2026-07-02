import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String initials;

  const Avatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CircleAvatar(
      radius: 60,
      backgroundColor: colors.border,
      child: Text(initials, style: context.pStrong.copyWith(fontSize: 20)),
    );
  }
}
