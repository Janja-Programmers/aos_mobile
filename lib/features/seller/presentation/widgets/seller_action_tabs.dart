import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class SellerActionTabs extends StatelessWidget {
  const SellerActionTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _ActionBtn(icon: Icons.edit, label: 'Edit'),
        _ActionBtn(icon: Icons.palette, label: 'Customize'),
        _ActionBtn(icon: Icons.share, label: 'Share'),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.border,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.p.copyWith(
                overflow: TextOverflow.ellipsis,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
