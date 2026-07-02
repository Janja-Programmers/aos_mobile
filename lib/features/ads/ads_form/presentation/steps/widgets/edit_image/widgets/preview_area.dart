import 'dart:io';

import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class PreviewArea extends StatelessWidget {
  const PreviewArea({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              file,
              key: ValueKey(file.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
