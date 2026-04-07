import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final theme = Theme.of(context);
  final colors = context.appColors;

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    lastDate: lastDate ?? DateTime(2100),
    initialEntryMode: DatePickerEntryMode.calendar,

    builder: (context, child) {
      return Theme(
        data: theme.copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: colors.surface,

            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primary;
              }
              return colors.surface;
            }),

            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.white;
              }

              if (states.contains(WidgetState.disabled)) {
                return colors.border;
              }

              return colors.textPrimary;
            }),

            todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (!states.contains(WidgetState.selected)) {
                return colors.border;
              }
              return colors.primary;
            }),

            todayForegroundColor: WidgetStateProperty.all(colors.white),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.surface),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
