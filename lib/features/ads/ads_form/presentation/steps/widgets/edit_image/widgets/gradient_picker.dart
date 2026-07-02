import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class GradientPicker extends StatelessWidget {
  const GradientPicker({
    super.key,
    required this.onSelect,
    required this.selectedGradient,
    required this.isApplying,
  });

  final ValueChanged<List<Color>> onSelect;
  final List<Color>? selectedGradient;
  final bool isApplying;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [Colors.orange, Colors.pink],
      [Colors.blue, Colors.purple],
      [Colors.green, Colors.teal],
      [Colors.black, Colors.grey],
      [Colors.red, Colors.orange],
      [Colors.cyan, Colors.blue],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Gradients',
          trailing: isApplying ? 'Applying...' : null,
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 54,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final gradient = gradients[i];
              final selected = _sameGradient(selectedGradient, gradient);

              return _GradientChip(
                gradient: gradient,
                selected: selected,
                loading: selected && isApplying,
                onTap: () => onSelect(gradient),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: gradients.length,
          ),
        ),
      ],
    );
  }

  bool _sameGradient(List<Color>? a, List<Color> b) {
    if (a == null || a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i].toARGB32() != b[i].toARGB32()) return false;
    }

    return true;
  }
}

class _GradientChip extends StatelessWidget {
  const _GradientChip({
    required this.gradient,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  final List<Color> gradient;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 68,
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: gradient),
              border: Border.all(color: colors.border),
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
                        key: const ValueKey('gradient_loader'),
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                    : selected
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('gradient_check'),
                        color: colors.primary,
                        size: 20,
                      )
                    : const SizedBox(
                        key: ValueKey('gradient_empty'),
                        height: 20,
                        width: 20,
                      ),
              ),
            ),
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
