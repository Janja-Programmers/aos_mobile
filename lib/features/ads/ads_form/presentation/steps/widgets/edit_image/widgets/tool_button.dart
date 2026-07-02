import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.loading = false,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final isDisabled = disabled || loading || onTap == null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isDisabled && !loading ? 0.45 : 1,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: active
                    ? colors.red.withValues(alpha: 0.08)
                    : colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? colors.red : colors.border,
                  width: active ? 1.4 : 1,
                ),
                boxShadow: loading
                    ? [
                        BoxShadow(
                          color: colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: active ? colors.red : colors.textPrimary,
                        ),
                      )
                    : Icon(
                        icon,
                        color: active ? colors.red : colors.textPrimary,
                      ),
              ),
            ),

            const SizedBox(height: 6),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                loading ? 'Working...' : label,
                key: ValueKey(loading ? 'loading_$label' : label),
                style: context.p.copyWith(
                  color: active ? colors.red : colors.textPrimary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
