import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PostMetric extends StatelessWidget {
  const PostMetric({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13),
        const SizedBox(width: 3),
        Text(label, style: context.small),
      ],
    );
  }
}
