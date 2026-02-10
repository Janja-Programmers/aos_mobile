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

  static const InputBorder _noBorder = InputBorder.none;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final borderColor = scheme.primary;
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

                  prefixIcon: Icon(Icons.search, size: 20, color: iconColor),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),

                  // ✅ ensure NO TextField border of any kind
                  border: _noBorder,
                  enabledBorder: _noBorder,
                  focusedBorder: _noBorder,
                  disabledBorder: _noBorder,
                  errorBorder: _noBorder,
                  focusedErrorBorder: _noBorder,

                  // ✅ also prevent filled/outline behavior
                  filled: false,
                  fillColor: Colors.transparent,

                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.only(top: 2),
                ),
              ),
            ),

            if (onMicTap != null) ...[
              _TinyIconButton(
                icon: Icons.mic_none,
                color: iconColor,
                onTap: onMicTap!,
              ),
            ],

            if (onMicTap != null && onCameraTap != null)
              const SizedBox(width: 8),

            if (onCameraTap != null) ...[
              _TinyIconButton(
                icon: Icons.camera_alt_outlined,
                color: iconColor,
                onTap: onCameraTap!,
              ),
            ],
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
        width: 28,
        height: 28,
        child: Center(child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}
