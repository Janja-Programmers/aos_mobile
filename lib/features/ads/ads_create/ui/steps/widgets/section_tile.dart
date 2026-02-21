import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: context.h5);
  }
}
