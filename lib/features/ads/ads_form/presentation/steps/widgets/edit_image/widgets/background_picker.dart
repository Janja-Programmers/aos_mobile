import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class BackgroundPicker extends StatelessWidget {
  const BackgroundPicker({
    super.key,
    required this.onSelect,
    required this.selectedColor,
    required this.isApplying,
  });

  final ValueChanged<Color?> onSelect;
  final Color? selectedColor;
  final bool isApplying;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.brown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Background Color',
          trailing: isApplying ? 'Applying...' : null,
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final color = colors[i];
              final selected = selectedColor?.toARGB32() == color.toARGB32();

              return _ColorChip(
                color: color,
                selected: selected,
                loading: selected && isApplying,
                onTap: () => onSelect(color),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: colors.length,
          ),
        ),

        const SizedBox(height: 14),

        _TransparentChip(
          selected: selectedColor == null,
          loading: selectedColor == null && isApplying,
          onTap: () => onSelect(null),
        ),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final themeColors = context.appColors;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? themeColors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: themeColors.border),
              boxShadow: [
                BoxShadow(
                  blurRadius: selected ? 8 : 3,
                  offset: const Offset(0, 2),
                  color: Colors.black.withValues(alpha: selected ? 0.18 : 0.08),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: loading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        height: 17,
                        width: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _indicatorColorFor(color),
                        ),
                      )
                    : selected
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('check'),
                        size: 18,
                        color: _indicatorColorFor(color),
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        height: 18,
                        width: 18,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _indicatorColorFor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

class _TransparentChip extends StatelessWidget {
  const _TransparentChip({
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: selected
          ? Colors.black.withValues(alpha: 0.06)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? colors.red : colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: loading
                    ? SizedBox(
                        key: const ValueKey('transparent_loader'),
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                    : Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.layers_clear_rounded,
                        key: ValueKey(selected),
                        size: 20,
                        color: colors.primary,
                      ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Transparent',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
