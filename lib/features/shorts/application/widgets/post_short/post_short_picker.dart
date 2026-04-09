import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PostShortPicker extends StatelessWidget {
  final VoidCallback onPick;

  const PostShortPicker({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F10), Color(0xFF17181C), Color(0xFF0B0B0C)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(.50),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.white.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.video_library_rounded,
                    color: colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create a Short',
                    style: context.pStrong.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      'Select Video',
                      style: context.p.copyWith(color: colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
