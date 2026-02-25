import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ScheduleOfferCard extends StatelessWidget {
  const ScheduleOfferCard({
    super.key,
    required this.enabled,
    required this.startDate,
    required this.endDate,
    required this.onToggle,
    required this.onStartPicked,
    required this.onEndPicked,
  });

  final bool enabled;
  final DateTime? startDate;
  final DateTime? endDate;

  final ValueChanged<bool> onToggle;
  final ValueChanged<DateTime?> onStartPicked;
  final ValueChanged<DateTime?> onEndPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          /// Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text('Schedule Offer Dates', style: context.pStrong),
              ),

              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeColor: colors.primary,
              ),
            ],
          ),

          if (enabled) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DateBox(
                    label: 'From',
                    date: startDate,
                    onPicked: onStartPicked,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DateBox(
                    label: 'To',
                    date: endDate,
                    onPicked: onEndPicked,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class DateBox extends StatelessWidget {
  const DateBox({
    super.key,
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.pMuted),

        const SizedBox(height: 6),

        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );

            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    date != null
                        ? '${date!.year}-${date!.month}-${date!.day}'
                        : label == 'From'
                        ? 'Start date'
                        : 'End date',
                    style: context.p,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
