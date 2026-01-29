import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onMicTap,
    this.onCameraTap,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController? controller;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final borderColor = colors.border;
    final iconColor = colors.textMuted;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: iconColor),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurface,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: TextStyle(fontSize: 15, color: iconColor),

                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,

                  filled: false,
                  fillColor: Colors.transparent,

                  isDense: true,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            _TinyIconButton(
              icon: Icons.mic_none,
              color: iconColor,
              onTap: onMicTap ?? () {},
            ),
            const SizedBox(width: 8),
            _TinyIconButton(
              icon: Icons.camera_alt_outlined,
              color: iconColor,
              onTap: onCameraTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 28, // tight like the image
        height: 28,
        child: Center(child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}
