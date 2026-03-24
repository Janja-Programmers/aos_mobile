import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class MediaAddTile extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final bool loading;

  const MediaAddTile({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colors.red),
                    const SizedBox(height: 6),
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
