import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class OperatingHoursSection extends StatelessWidget {
  const OperatingHoursSection({
    super.key,
    required this.dayEnabled,
    required this.openTimes,
    required this.closeTimes,
    required this.onOpenTimeTap,
    required this.onCloseTimeTap,
    required this.onDayChanged,
  });

  final Map<String, bool> dayEnabled;
  final Map<String, TimeOfDay> openTimes;
  final Map<String, TimeOfDay> closeTimes;
  final void Function(String day) onOpenTimeTap;
  final void Function(String day) onCloseTimeTap;
  final void Function(String day, bool enabled) onDayChanged;

  String _format(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final days = dayEnabled.keys.toList();
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: days.map((day) {
          final enabled = dayEnabled[day] ?? false;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              border: Border(
                bottom: day == days.last
                    ? BorderSide.none
                    : BorderSide(color: colors.border),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: enabled,
                  activeColor: colors.primary,
                  checkColor: colors.white,
                  onChanged: (value) {
                    onDayChanged(day, value ?? false);
                  },
                ),

                Expanded(child: Text(day, style: context.p)),

                if (enabled) ...[
                  _TimePill(
                    label: _format(openTimes[day]!),
                    onTap: () => onOpenTimeTap(day),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-'),
                  ),
                  _TimePill(
                    label: _format(closeTimes[day]!),
                    onTap: () => onCloseTimeTap(day),
                  ),
                ] else
                  Text('Closed', style: context.pMuted),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 62,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: context.small.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 18),
        const SizedBox(width: 8),
        Text(label, style: context.p.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
