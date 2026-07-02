import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:flutter/material.dart';

class OperatingHoursForm {
  OperatingHoursForm({
    Map<String, bool>? dayEnabled,
    Map<String, TimeOfDay>? openTimes,
    Map<String, TimeOfDay>? closeTimes,
  }) : dayEnabled = dayEnabled ?? _defaultDayEnabled(),
       openTimes = openTimes ?? _defaultOpenTimes(),
       closeTimes = closeTimes ?? _defaultCloseTimes();

  final Map<String, bool> dayEnabled;
  final Map<String, TimeOfDay> openTimes;
  final Map<String, TimeOfDay> closeTimes;

  List<Map<String, dynamic>> toApiPayload() {
    return dayEnabled.keys
        .map((day) {
          final isOpen = dayEnabled[day] ?? false;

          return {
            'day_of_week': _dayCode(day),
            'is_open': isOpen ? 1 : 0,
            if (isOpen) 'open_time': _formatTimeForApi(openTimes[day]!),
            if (isOpen) 'close_time': _formatTimeForApi(closeTimes[day]!),
          };
        })
        .toList(growable: false);
  }

  void hydrate(List<Object?> hours) {
    if (hours.isEmpty) return;

    for (final raw in hours) {
      if (raw is! Map) continue;

      final item = asJsonMap(raw);
      final day = _fullDayName(item['day_of_week']?.toString());

      if (day == null) continue;

      final isOpen = _parseBool(item['is_open']);

      dayEnabled[day] = isOpen;

      final openTime = _parseTimeOfDay(item['open_time']?.toString());
      final closeTime = _parseTimeOfDay(item['close_time']?.toString());

      if (openTime != null) {
        openTimes[day] = openTime;
      }

      if (closeTime != null) {
        closeTimes[day] = closeTime;
      }
    }
  }

  static Map<String, bool> _defaultDayEnabled() {
    return {
      'Monday': true,
      'Tuesday': true,
      'Wednesday': true,
      'Thursday': true,
      'Friday': true,
      'Saturday': true,
      'Sunday': false,
    };
  }

  static Map<String, TimeOfDay> _defaultOpenTimes() {
    return {
      'Monday': const TimeOfDay(hour: 9, minute: 0),
      'Tuesday': const TimeOfDay(hour: 9, minute: 0),
      'Wednesday': const TimeOfDay(hour: 9, minute: 0),
      'Thursday': const TimeOfDay(hour: 9, minute: 0),
      'Friday': const TimeOfDay(hour: 9, minute: 0),
      'Saturday': const TimeOfDay(hour: 10, minute: 0),
      'Sunday': const TimeOfDay(hour: 9, minute: 0),
    };
  }

  static Map<String, TimeOfDay> _defaultCloseTimes() {
    return {
      'Monday': const TimeOfDay(hour: 18, minute: 0),
      'Tuesday': const TimeOfDay(hour: 18, minute: 0),
      'Wednesday': const TimeOfDay(hour: 18, minute: 0),
      'Thursday': const TimeOfDay(hour: 18, minute: 0),
      'Friday': const TimeOfDay(hour: 18, minute: 0),
      'Saturday': const TimeOfDay(hour: 16, minute: 0),
      'Sunday': const TimeOfDay(hour: 18, minute: 0),
    };
  }

  static String _dayCode(String day) {
    switch (day) {
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      case 'Sunday':
        return 'Sun';
      default:
        return day;
    }
  }

  static String? _fullDayName(String? value) {
    switch (value) {
      case 'Mon':
      case 'Monday':
        return 'Monday';
      case 'Tue':
      case 'Tuesday':
        return 'Tuesday';
      case 'Wed':
      case 'Wednesday':
        return 'Wednesday';
      case 'Thu':
      case 'Thursday':
        return 'Thursday';
      case 'Fri':
      case 'Friday':
        return 'Friday';
      case 'Sat':
      case 'Saturday':
        return 'Saturday';
      case 'Sun':
      case 'Sunday':
        return 'Sunday';
      default:
        return null;
    }
  }

  static String _formatTimeForApi(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  static TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parts = value.split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == '1' || raw == 'true' || raw == 'yes';
  }
}
